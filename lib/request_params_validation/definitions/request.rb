require 'request_params_validation/definitions/param'

module RequestParamsValidation
  module Definitions
    class Request
      attr_reader :params

      def initialize
        @params = []
      end

      def required(param_name, options = {}, &block)
        options = options.merge({ required: true })
        add_parameter(param_name, options, &block)
      end

      def optional(param_name, options = {}, &block)
        options = options.merge({ required: false })
        add_parameter(param_name, options, &block)
      end

      private

      def add_parameter(name, options, &block)
        options = options.merge({ key: name })

        @params << Param.new(options, &block)
      end
    end
  end
end
