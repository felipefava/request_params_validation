require 'request_params_validation/definitions/request'

module RequestParamsValidation
  module Definitions
    class Action
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def request(&block)
        if block_given?
          @request = Request.new

          @request.instance_eval(&block)
        else
          @request
        end
      end
    end
  end
end
