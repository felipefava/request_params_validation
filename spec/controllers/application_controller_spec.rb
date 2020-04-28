Dir[Rails.root.join('../request_params_validation/**/*.rb')].each { |f| require f }

RSpec.describe ApplicationController do
  include_examples 'definitions'

  include_examples 'validates presence'
  include_examples 'validates type'
  include_examples 'validates inclusion'
  include_examples 'validates length'
  include_examples 'validates value size'
  include_examples 'validates format'
  include_examples 'validates custom validations'

  include_examples 'params default values'
  include_examples 'params transformations'

  include_examples 'coerce params'
  include_examples 'filter params'

  include_examples'global configurations'
end
