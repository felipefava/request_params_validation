RSpec.describe ApplicationController do
  include_examples 'validates presence'
  include_examples 'validates type'
  include_examples 'validates inclusion'
end
