module RequestParamsValidation
  autoload :Definitions, 'request_params_validation/definitions'
  autoload :Helpers,     'request_params_validation/helpers'

  class Engine < ::Rails::Engine
    isolate_namespace RequestParamsValidation

    initializer 'request_params_validation.load_definitions' do
      RequestParamsValidation::Definitions.load_all
    end

    initializer 'request_params_validation.add_helpers' do
      ActiveSupport.on_load :action_controller do
        include RequestParamsValidation::Helpers
      end
    end
  end
end
