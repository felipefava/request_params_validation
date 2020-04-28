require 'request_params_validation/exceptions/base_errors'

module RequestParamsValidation
  class MissingParameterError < RequestParamError
    attr_reader :param_key, :param_type

    def initialize(options)
      @param_key   = options[:param_key]
      @param_type  = options[:param_type]

      super(message)
    end

    def message
      "The parameter '#{param_key}' is missing"
    end
  end

  class InvalidParameterValueError < RequestParamError
    attr_reader :param_key, :param_value, :param_type, :details

    def initialize(options)
      @param_key   = options[:param_key]
      @param_value = options[:param_value]
      @param_type  = options[:param_type]
      @details     = options[:details]

      super(message)
    end

    def message
      message = "The value for the parameter '#{param_key}' is invalid"

      if details.present?
        "#{message}. #{details}"
      else
        message
      end
    end
  end

  class UnsupportedTypeError < GeneralError
    def initialize(options)
      msg = "Unsupported type '#{options[:param_type]}' for the parameter '#{options[:param_key]}'"

      super(msg)
    end
  end
end
