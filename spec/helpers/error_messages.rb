module Helpers
  module ErrorMessages
    def build_error_response(error_type, param_key:, details: nil)
      case error_type
      when :missing_param
        response_for_missing_param(param_key)
      when :invalid_param
        response_for_invalid_param(param_key, details)
      end
    end

    def response_for_missing_param(param_key)
      {
        status: :error,
        key: 'RequestParamsValidation::MissingParameterError',
        message: "The parameter '#{param_key}' is missing"
      }.to_json
    end

    def response_for_invalid_param(param_key, details)
      {
        status: :error,
        key: 'RequestParamsValidation::InvalidParameterValueError',
        message: error_msg_for_invalid_param(param_key, details)
      }.to_json
    end

    def error_msg_for_invalid_param(param_key, details = nil)
      message = "The value for the parameter '#{param_key}' is invalid"

      return message unless details

      "#{message}. #{details}"
    end
  end
end
