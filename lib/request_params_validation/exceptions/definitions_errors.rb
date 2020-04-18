require 'request_params_validation/exceptions/base_errors'

module RequestParamsValidation
  class DefinitionNotFoundError < DefinitionsError
    def initialize(resource, action)
      msg = "The request definition for the resource '#{resource}' and action '#{action}' " \
            "couldn't be found"

      super(msg)
    end
  end

  class DefinitionArgumentError < DefinitionsError
    attr_accessor :resource, :action

    def initialize(error_msg, options = {})
      @error_msg = error_msg
      @resource  = options[:resource]
      @action    = options[:action]
    end

    def message
      if resource && action
        "Argument error for resource '#{resource}' and action '#{action}'. #{@error_msg}"
      elsif resource
        "Argument error for resource '#{resource}'. #{@error_msg}"
      else
        @error_msg
      end
    end
  end
end
