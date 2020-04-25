RSpec.describe ApplicationController do
  include_examples 'validates presence'
  include_examples 'validates type'
  include_examples 'validates inclusion'
  include_examples 'validates length'
  include_examples 'validates value'
  include_examples 'validates format'
end
