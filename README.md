# RequestParamsValidation
_Request parameters validations, type coercion and filtering for Rails params_

## Introduction
Validates the request params outside your controller logic in order to get a clean nice code, and
also working as code documentation for the operations. It ensure that all endpoint input data is
right and well formed before it even hits your controller action.

This gem allows you to validate the presence, type, length, format, value and more, of your request
parameters. It also coerces the params to the specified type and filter the hash to only those you
expect to receive.

It is designed to work for any expected params structure, from a simple hash to a complex one with
deeply nested data. It pretends to be a flexible library where you can change and customize
several options.


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'request_params_validation'
```

And then execute `bundle install` from your shell.

Or, if you want to install it manually, run:
```ruby
gem install request_params_validation
```

## Usage
To starting using the gem without setting in any configuration is as simple as adding a
`before_action` with the helper method `validate_params!` and define your expected request
parameters for your resources actions. If no definition is found for a specific endpoint, the
default behaviour is to do nothing, that means, no validation will be executed and the params will
be untouch as if the gem doesn't exist.

This gem comes with a set of configurable options pretending to be a flexible library, here you can
see all the allowed configurations. However, all config has default values, so if you don't feel
the need of change any out of the box behaviour,youo dont need to worry. In the future, the plan is
to add more configurable options and behaviours.

## Example
Add the `before_action` callback for all actions:

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  before_action :validate_params!
end
```

Imagine we have the following resource and we want to define the params for the action `create`
and `notify`:

```ruby
# app/controllers/users_controller.rb

class UsersController < ApplicationController
  def create
    ...
  end

  def notify
    ...
  end

  def another_action
    ...
  end
end
```

Then, we will need to create the definition for the `users` resource:

```ruby
# app/definitions/users_definition.rb

RequestParamsValidation.define do |users|
  users.action :create do |create|
    users.request do |params|
      params.required :user, type: :hash do |user|
        user.required :first_name, type: :string
        user.required :last_name, type: :string
        user.required :emails, type: :array, elements: :email
        user.required :birth_date,
                      type: :datetime,
                      validate: lambda { |value| value <= 18.years.ago.to_date }
      end
    end
  end

  users.action :notify do |notify|
    notify.request do |params|
      params.required :user_id, type: :integer
      params.required :message, type: :string, length: { min: 10 }
      params.optional :by, inclusion: %w(email text_msg push), default: :email
    end
  end
end
```

The above definition is just a silly example, but is good enough to explain some things.

The first thing to say is that each controller file matches with a definition file with the same
name and path of it. This means that if we have a controller in
`app/commerces/branches_controller.rb`, then we will have the definition in
`app/definitions/commerces/branches_definition.rb`, assuming we have all the default configuration.
If the definition file doesn't exist for a controller, then the gem will not validate
any param.

Explaining this, we can continue analyzing the above example. The method
`RequestParamsValidation.define` allow you to define a resource. Notice that the defined resource
is given by the current file path/name. After defining the resource, you can continue defining the
actions for that resource with the `action` method. Then, for each action you can define the
request using the `request` method, and there is where you will define the params validations for
the current resource/action. You could think that the `request` step is not strictly necessary,
because we could just defined the params validations inside de action block. However, it will have
more sense in the future, when more extra options be added.

As you might notice, for defining required parameters we use the `required` method, otherwise
we have the `optional` method. This two methods accept 2 arguments and a block. The first argument
is the only one required, and is the name or key of the parameter. The second argument is an
options hash for specifing the extra validations, and the block is for defining nested params.

In the following section we will see all the options validations in-depth look.

## Validations & Options
None of the below options are required, so they can be omitted if you don't need to use them.

### Presence
If a parameter is required, then you should use the `required` method on the definition of the
param. Otherwise use the `optional` method. For default, required parameters don't accept blank
values, if you would like to allow them for that parameter, you can use the option `allow_blank`

```ruby
some_action.request do |params|
  params.required :key_1
  params.required :key_2, allow_blank: true
  params.optional :key_3
end
```

### Types
The `type` option specified the type of the parameter. The supported types are:

1. hash
2. array
3. string
4. integer
5. decimal
6. boolean
7. date
9. datetime
9. email

So if this option is present, the gem will validate that the value of the parameter matches with
the specified type. And if it does, it will convert the value to the right type. This means that
if a parameter should be an `integer`, a valid string integer like `"100"` will be converter to
`100`. The same applies to the other types.

If you want to add your own types, you can extend the supported types with the global
configuration option `extend.types`. See [here](#global_configurations) all globals configuration options.

```ruby
some_action.request do |params|
  params.required :key_1, type: :boolean
  params.required :key_2, type: :decimal
end
```

#### Hash type
When defining a hash parameter, you will need to pass a block for specifing the nested object.

```ruby
some_action.request do |params|
  params.required :key_name, type: :hash do |key_name|
    key_name.required :nested_key_1, type: :string
    key_name.required :nested_key_2, type: :integer
  end
end
```

#### Array type
If you define an array parameter, the gem will only check the value to be a valid array, allowing
 the elements of the array to be anything. If you also want to validate the elements, you can use
 the option `elements`.

The value for this option can be a type or a hash. `elements: :integer` is equivalent to
`elements: { type: :integer }`.

The second way is useful when you  want to validate other things of the elements than just the
type. The option elements accepts all validations options.

```ruby
some_action.request do |params|
  # Allows any value for the elements of the array
  params.required :key_1, type: :array

  # Only allows decimals with a value less than 1_000 for the elements of the array
  params.required :key_2, type: :array, elements: { type: :decimals, value: { max: 1_000 }

  # Only allows objects with a required key 'nested_key' of type 'email' for the
  # elements of the array
  params.required :key_3, type: :array, elements: :hash do |key_3|
    key_3.required :nested_key, type: :email
  end
end
```

#### String type
Any value is a valid string.

#### Integer type
Accepts only valid integers like `5` or `"5"`.

#### Decimal type
Accepts only valid decimals like `5` or `1.5` or `10.45`. With decimals parameters you can use
the option `precision`. Continue reading for more details about this option.

#### Boolean type
Accepts only valid boolean values. The default valid boolean values are:

```ruby
[true, false, 'true', 'false']
```

If you need to add more values for the boolean type, for example  `['yes', 'no', 1, 0, 't', 'f']`,
you can extend the `true values` and the `false values` independently, with the global
configuration options `extend.boolean_true_values` and `extend.boolean_false_values` respectively.
See [here](#global_configurations) all globals configuration options.

#### Date type
Date type accepts only valid dates. This means that values like `'04/10/1995'` are valids, and
will be converter to a Date object like  `Wed, 04 Oct 1995`.

However, there are cases when you only want to accept a specific format for a date, like
`"%Y-%m-%e"`. In this cases you have two options.

1. Use the global configuration option `format.date`, so all date types must have the specified
   format through all the requests. See [here](#global_configurations) all globals configuration options.
2. Specify the option `format: "%Y-%m-%e"` locally.

You can perfectly use both approaches, but the second one will locally override the first one on
that parameter validation.

Notice that if no format is specified, the date will be validated using the ruby `Date.parse`
method.

```ruby
some_action.request do |params|
  params.required :key_1, type: :date
  params.required :key_2, type: :date, format: '%Y-%m-%e'
end
```

#### Datetime type
Same as `date` type but for `datetime`.

#### Email type
Accepts only valid emails like `john.doe@mail.com`. It's just a helper for a string type with
an email regexp format.

### Inclusion
The `inclusion` option is for validating that the param value is included in a given set.
In fact, this set can be any enumerable object.

The value for this option can be an enumerable or a hash. `inclusion: %w(asc desc)` is equivalent
to `inclusion: { in: %w(asc desc) }`.

Besides from the `in` option, you can also use the `message` option for passing a custom error
detail when the parameter is not valid.

```ruby
some_action.request do |params|
  params.required :key_1, type: :string, inclusion: %w(asc desc)
  params.required :key_2,
                  type: :string,
                  inclusion: { in: %w(s m l), message: 'Value is not a valid size' }
end
```

### Length
The `length` option is for validating the length of the param value.

The value for this option can be an integer or a hash. `length: 5` is equivalent
to `length: { min: 5, max: 5 }`.

Besides from the `min` and `max` options, you can also use the `message` option for passing a
custom error detail when the parameter is not valid.

```ruby
some_action.request do |params|
  params.required :key_1, type: :string, length: 10
  params.required :key_2, type: :string, length: { min: 5, max: 12 }
  params.required :key_3, type: :array, elements: :email, length: { max: 3 }
  params.required :key_4, type: :string, length: { max: 25,
                                                   message: '25 characters is the maximum allowed' }
end
```

### Value Size
The `value` option is for validating the value size of numerics parameters.

The value for this option is a hash with the following options: `min`, `max` and `message`.

```ruby
some_action.request do |params|
  params.required :key_1, type: :integer, value: { min: 0 }
  params.required :key_2, type: :integer, value: { max: 1_000_000, message: 'Value too big!' }
  params.required :key_3, type: :decimal, value: { min: 0, max: 1 }
end
```

### Format
The `format` option allows to validate de format of the value with a regular expression.

The value for this option is a `regexp`, `string` or a `hash`. The string value is only valid
when the type is a `date` or a `datetime`. Otherwise, you should use a regexp. The options for
the hash are: `regexp`, `strptime` and `message`.

So, for `date` and `datetime` types, `format: '%u%F'` is equivalent to
`format: { strptime: '%u%F' }`. For the other types, `format: /^5[1-5]\d{14}$/` is
equivalent to `format: { regexp: /^5[1-5]\d{14}$/ }`.

```ruby
some_action.request do |params|
  params.required :key_1, type: :string, format: /^5[1-5]\d{14}$/
  params.required :key_2, type: :string, format: { regexp: /^1.*/,
                                                   message: 'Value should start with a 1' }
end
```

### Custom Validation
You can add custom validations to the parameter with the option `validate`.

This option accepts a Proc as value or a hash. For example,
`validate: lambda { |value| value > Date.today }` is equivalent to
`validate: { function: lambda { |value| value > Date.today } }`. However, the hash value
also accepts the `message` option.

```ruby
some_action.request do |params|
  params.required :key_1, type: :date, validate: { function: lambda { |value| value >= Date.today },
                                                   message: 'The date can not be in the past.' }
end
```

### Precision
The `precision` option are for `decimal` types. This option does not execute any validation
on the value of the parameter, but it will round the decimal when the value is converter to
the specified type.

If you want to set a precision value to all `decimal` parameters, you can use the global
configuration option `format.decimal_precision`. Keep in mind that if you set the `precision`
option on a parameter, it will locally override the global configuration. See here for all
globals configuration options.

This option accepts an integer as value.

```ruby
some_action.request do |params|
  params.required :key_1, type: :decimal, precision: 2
end
```

### Default Values
When parameters are optional, with the `default` option you can set a default value when the parameter is not
present.

The value for the option `default` could be anything, including a proc.

```ruby
some_action.request do |params|
  params.optional :key_1, type: :string, default: 'Jane'
  params.optional :key_2, type: :string, default: lambda { Date.today.strftime('%A') }
end
```

### Transformations
Transformations are functions that are called to the value of the parameter, after it has already
been validated. The option for this is `transform`.

The `transform` option could be a symbol, or a proc. The proc will receive the value of the
parameter as an argument, so keep in mind that the value will be already of the type
specified in the definition. So, `transform: :strip` is equivalent to
`transform: lambda { |value| value.strip }`.

```ruby
some_action.request do |params|
  params.optional :key_1, type: :string, transform: :strip
  params.optional :key_2,
                  type: :string,
                  format: /^\d{3}-\d{3}-\d{3}$/,
                  transform: lambda { |value| value.gsub(/-/, '') }
end
```

<br>

---
**NOTE**

RequestParamsValidation will start validating the presence of the parameters. Then, if the value is
not present and the parameter has a default value, it will assign that value and not execute any
further validation. Otherwise, it will validate the type, convert it to the right type and then
continue with the others validations. So, all others validations will be executed with the parameter
value already converter to the specified type, so keep in mind that at defining the validations.

---

## Errors & Messages
For default, when a required parameter failed the presence validation, the exception
`RequestParamsValidation::MissingParameterError` will be raised. If it failed for any of the others
validations, the raised exception will be `RequestParamsValidation::InvalidParameterValueError`
with a proper descriptive error message.

This two exceptions inherits from `RequestParamsValidation::RequestParamError`, so you
can rescue the exceptions like this:

```ruby
# app/controllers/application_controller.rb

class ApplicationController < ActionController::Base
  rescue_from RequestParamsValidation::RequestParamError do |exception|
    # do whatever you want
  end
end
```

Both exceptions has getters methods to access data related to the failure. For example, the
`RequestParamsValidation::MissingParameterError` exception has two public methods `param_key`
and `param_type` for getting the name and type of the parameter which failed. And the
`RequestParamsValidation::InvalidParameterValueError` exception has the two mentioned methods,
plus the methods `param_value` and `details`. `param_value` returns the value of the parameter,
and `details` give more information about the reason of the failure.

### Errors messages
For the exception `RequestParamsValidation::MissingParameterError`, the error message is the
following:

```ruby
"The parameter '#{param_key}' is missing"
```

And for `RequestParamsValidation::InvalidParameterValueError` the message is:

```ruby
"The value for the parameter '#{param_key}' is invalid"
```

Or, if `details` is present:

```ruby
"The value for the parameter '#{param_key}' is invalid. #{details}"
```

The details is different depending on the reason of the failure, and whether the parameter is
an element of an array or not. If you **have specified the `message` option in the parameter
definition**, then the details will be that value, otherwise it will took a default value from
the table below:


| Failure                   | Default Message                                      |
| ------------------------- | ---------------------------------------------------- |
| Missing parameter         | N/A                                                  |
| Invalid type              | - `Value should be a valid %{param_type}` <br> - `All elements should be a valid %{type}` <br> If has `date` or `datetime` type with specified `format`: <br> &nbsp;&nbsp;&nbsp; - ` with the format %{format}` string is concatenated |
| Invalid inclusion         | - `Value should be in %{include_in}` <br> - `All elements values should have be in %{include_in}` |
| Invalid length            | - `Length shoud be greater or equal than %{min}` <br> - `Length shoud be less or equal than %{max}`  <br> - `Length shoud be equal to %{min/max}` </br> - `Length shoud be between %{min} and %{max}` <br> - `All elements should have a length ...` |
| Invalid value size        | - `Value shoud be greater or equal than %{min}` <br> - `Value shoud be less or equal than %{max}` <br> - `Value shoud be between %{min} and %{max}` <br> - `All elements should have a value ...` |
| Invalid format            | - `Value format is invalid` <br> - `An element has an invalid format` |
| Invalid custom validation | N/A                                                  |


### Custom Exceptions
However, if the above is not enough for your app, and you need to fully customize the exceptions
and the messages, you can setup your own exceptions classes for each type of failure. They are
globals configurations options that allow you to do that. See below to see them all.

## Global Configurations <a name='global_configurations'></a>
Global configurations help you to customize the gem to fulfill your needs. To change this
configuration, you need to create an initializer and setup what you want to change:

```ruby
# config/initializers/request_params_validation.rb

RequestParamsValidation.configure do |config|
  #... here goes the configuration
end
```

To see a complete initializer file with all the options and description of each of one
please see here.

## Future Work
In the near future the plan is to continue adding features to the gem. In order of
importance, next changes are:
- Add tests to all the app
- Add doc documentation from the definitions
- Add more options to the actions definitions
- Add handler for responses (i.e. json APIs)

## Credits
This gem is strongly inspired in a Ruby Framework named [Angus][https://github.com/moove-it/angus]
developed by [Moove It][https://moove-it.com/]

## Contributing
1. Fork it
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a Pull Request

## License
This software is released under the MIT license. See the MIT-LICENSE file for more info.
