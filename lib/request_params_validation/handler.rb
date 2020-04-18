require 'request_params_validation/definitions'
require 'request_params_validation/params'
require 'request_params_validation/exceptions/definitions_errors'

module RequestParamsValidation
  module Handler
    def self.handle_request_params(resource, action, params)
      request_definition = Definitions.get_request(resource, action)

      unless request_definition
        case RequestParamsValidation.on_definition_not_found
        when :raise
          raise DefinitionNotFoundError.new(resource, action)
        else
          return
        end
      end

      RequestParamsValidation.remove_keys_from_params.each { |key| params.delete(key) }

      Params.validate!(request_definition.params, params)

      Params.filter!(request_definition.params, params) if RequestParamsValidation.filter_params
    end
  end
end
