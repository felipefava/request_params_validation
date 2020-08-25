RequestParamsValidation.define do
  action :dummy do
    request do |params|
      # This is only for testing purpose.
      # It allows to change the params definition for each test case.
      ApplicationController.dummy_params_definition.call(params)
    end
  end
end
