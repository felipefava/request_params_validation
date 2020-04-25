RequestParamsValidation.define do |application|
  application.action :dummy do |dummy|
    dummy.request do |params|
      # This is only for testing purpose.
      # It allows to change the params definition for each test case.
      ApplicationController.dummy_params_definition[params]
    end
  end
end
