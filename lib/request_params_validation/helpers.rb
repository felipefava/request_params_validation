require 'request_params_validation/handler'

module RequestParamsValidation
  module Helpers
    define_method RequestParamsValidation.helper_method_name do
      resource = params[:controller]
      action = params[:action]

      if RequestParamsValidation.save_original_params
        original_params = params.deep_dup
        instance_variable_set(RequestParamsValidation.save_original_params, original_params)
      end

      Handler.handle_request_params(resource, action, params)
    end
  end
end
