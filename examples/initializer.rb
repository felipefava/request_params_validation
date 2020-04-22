RequestParamsValidation.configure do |config|

  # Define helper_method_name for specifing the name for the helper method
  # in charge of validating the request params.
  #
  # The default name is :validate_params!.
  #
  config.helper_method_name = :validate_params!


  # Specify the path starting from `Rails.root` where is going
  # to be the request params definitions files.
  #
  # Example:
  #   - config.definitions_path = :definitions
  # That means the params definitions should be in: "#{Rails.root}/definitions/**/*"
  #
  # The default path is :'app/definitions'.
  #
  config.definitions_path = :'app/definitions'


  # The on_definition_not_found option accepts two values: :nothing or :raise.
  # - :raise means that if the definition for a controller/action can not be found,
  #          it will raise RequestParamsValidation::DefinitionNotFound. This is useful when
  #          you want to validate all requests and be sure that no request will be
  #          executed without running validations.
  # - :nothing will do nothing and skip the validation for that controller/action.
  #
  # The default value is :nothing.
  #
  config.on_definition_not_found = :nothing


  # Set the filter_params to true if you want to overwrite the params and
  # stay with only those that are specified in the current controller/action definition.
  # If params is an ActionController::Parameters, it sets the permitted attribute to true.
  #
  # The default value is true.
  #
  config.filter_params = true


  # If you want for some reason to save the original params in an instance variable before
  # they get filtered, here you can set that variable.
  #
  # Example:
  #   - config.save_original_params = :@original_params
  #
  # The default value is false.
  #
  config.save_original_params = false


  # Rails automatically adds the keys 'controller' and 'action' to the params object. The gem
  # maintains those keys, but if you feel the need to remove them, you can set this option
  # as follow.
  #
  # Example:
  #   - config.remove_keys_from_params = %i(controller action)
  #
  # The default value is [].
  #
  config.remove_keys_from_params = []


  # Extension configuration goes here. Here you can extend behaviours and
  # default values of the gem.
  config.extend do |extend|

    # Set a module with all your custom types you want the gem to manage.
    # For example, if you want to add a custom type named "cellphone", you just need to
    # create a module which defines the method "valid_cellphone?(value)" and pass that module
    # to this configuration variable.
    #
    # You can also overwrite the existing type validation methods if you feel the
    # need to change the behaviour of a certain type.
    #
    # Note 1: the module should be in Rails autoload_paths or you would need to
    #         require it or autoload it before setting it.
    # Note 2: the defined methods should be named as `valid_#{type}?(value)`.
    # Note 3: the defined methods should return true or false.
    #
    # Example:
    #   - extend.types = Utils::ValidationTypes
    #
    # The default value is false.
    #
    extend.types = false


    # Add boolean true values that you want the gem to manage, behalf the default ones,
    # true and 'true'. For example, you can add the integer 1 or the string 't' or 'yes' etc.
    #
    # Example:
    #   - extend.boolean_true_values = [1, 't']
    #
    # The default value is []
    #
    extend.boolean_true_values = []


    # Add boolean false values that you want the gem to manage, behalf the default ones,
    # false and 'false'. For example, you can add the integer 0 or the string 'f' or 'no' etc.
    #
    # Example:
    #   - extend.boolean_false_values = [0, 'f']
    #
    # The default value is []
    #
    extend.boolean_false_values = []
  end


  # Formats configuration goes here. Here you can set the formats of different types, so this
  # configuration apply to all your definitions, avoiding to do it on each parameter.
  #
  # Notice that the local configuration of a definition will have more precedence
  # than this global ones.
  config.formats do |format|

    # Specify the format for the type "date". If not format is specified
    # then the Date.parse method will be used for the validation. Otherwise, it
    # will valid the format given using Date.strptime method.
    #
    # Note: The option "format" or "format -> strptime" on a date param definition will
    #       locally override this configuration for that parameter.
    #
    # Example:
    #   - formats.date = '%Y-%m-%d'
    #
    # The default value is nil.
    #
    format.date = nil


    # Specify the format for the type "datetime". If not format is specified
    # then the DateTime.parse method will be used for the validation. Otherwise, it
    # will valid the format given using DateTime.strptime method.
    #
    # Note: The option "format" or "format -> strptime" on a datetime param definition will
    #       locally override this configuration for that parameter.
    #
    # Example:
    #   - formats.datetime = '%Y-%m-%dT%H:%M:%S%z'
    #
    # The default value is nil.
    #
    format.datetime = nil


    # Specify the precision for the type "decimal". This option will not validate the decimal
    # precision of the requests, but it will round those decimal parameters to the specified
    # here when the value get converted to the right type.
    #
    # Note: The option "precision" on a decimal param definition will locally override this
    #       configuration for that parameter.
    #
    # The default value is nil. That means, no round.
    #
    format.decimal_precision = nil
  end


  # Exceptions configuration go here. You can set your own exception class for each
  # type of error. Having full control of the exception raised and the message of it.
  #
  # Notice that all default exceptions have getters for accesing data related to the
  # failure. You can also set custom messages details for the validations. See the
  # documentation for further details.
  #
  # Note that the classes set here should be in Rails autoload_paths or you would need to
  #      require it or autoload it before setting it
  config.exceptions do |exception|

    # Here you can set your custom exception class to be raisen when a required
    # parameter is missing.
    #
    # Note: The initializer of the class receives a hash argument with
    #       the following key => values:
    #         - param_key   => 'The parameter key/name'
    #         - param_value => 'The parameter value'
    #         - param_type  => 'The parameter type'
    #
    # The default value is RequestParamsValidation::MissingParameterError.
    #
    exceptions.on_missing_parameter = RequestParamsValidation::MissingParameterError


    # Here you can set your custom exception class to be raisen when the parameter type
    # option fails.
    #
    # Note: The initializer of the class receives a hash argument with
    #       the following key => values:
    #         - param_key   => 'The parameter key/name'
    #         - param_value => 'The parameter value'
    #         - param_type  => 'The parameter type'
    #         - details     => 'The details of the failure'
    #
    # The default value is RequestParamsValidation::InvalidParameterValueError.
    #
    exceptions.on_invalid_parameter_type = RequestParamsValidation::InvalidParameterValueError


    # Here you can set your custom exception class to be raisen when the parameter inclusion
    # option fails.
    #
    # Note: The initializer of the class receives a hash argument with
    #       the following key => values:
    #         - param_key   => 'The parameter key/name'
    #         - param_value => 'The parameter value'
    #         - param_type  => 'The parameter type'
    #         - include_in  => 'The array of the inclusion option'
    #         - details     => 'The details of the failure'
    #
    # The default value is RequestParamsValidation::InvalidParameterValueError.
    #
    exceptions.on_invalid_parameter_inclusion = RequestParamsValidation::InvalidParameterValueError


    # Here you can set your custom exception class to be raisen when the parameter length
    # option fails.
    #
    # Note: The initializer of the class receives a hash argument with
    #       the following key => values:
    #         - param_key   => 'The parameter key/name'
    #         - param_value => 'The parameter value'
    #         - param_type  => 'The parameter type'
    #         - min         => 'The min value of the length option'
    #         - max         => 'The max value of the length option'
    #         - details     => 'The details of the failure'
    #
    # The default value is RequestParamsValidation::InvalidParameterValueError.
    #
    exceptions.on_invalid_parameter_length = RequestParamsValidation::InvalidParameterValueError


    # Here you can set your custom exception class to be raisen when the parameter value
    # option fails.
    #
    # Note: The initializer of the class receives a hash argument with
    #       the following key => values:
    #         - param_key   => 'The parameter key/name'
    #         - param_value => 'The parameter value'
    #         - param_type  => 'The parameter type'
    #         - min         => 'The min value of the value option'
    #         - max         => 'The max value of the value option'
    #         - details     => 'The details of the failure'
    #
    # The default value is RequestParamsValidation::InvalidParameterValueError.
    #
    exceptions.on_invalid_parameter_value_size = RequestParamsValidation::InvalidParameterValueError


    # Here you can set your custom exception class to be raisen when the parameter format
    # option fails.
    #
    # Note: The initializer of the class receives a hash argument with
    #       the following key => values:
    #         - param_key   => 'The parameter key/name'
    #         - param_value => 'The parameter value'
    #         - param_type  => 'The parameter type'
    #         - regexp      => 'The regexp of the format option'
    #         - details     => 'The details of the failure'
    #
    # The default value is RequestParamsValidation::InvalidParameterValueError.
    #
    exceptions.on_invalid_parameter_format = RequestParamsValidation::InvalidParameterValueError


    # Here you can set your custom exception class to be raisen when the parameter validate
    # option fails.
    #
    # Note: The initializer of the class receives a hash argument with
    #       the following key => values:
    #         - param_key   => 'The parameter key/name'
    #         - param_value => 'The parameter value'
    #         - param_type  => 'The parameter type'
    #         - details     => 'The details of the failure'
    #
    # The default value is RequestParamsValidation::InvalidParameterValueError.
    #
    exceptions.on_invalid_parameter_custom_validation = RequestParamsValidation::InvalidParameterValueError
  end
end
