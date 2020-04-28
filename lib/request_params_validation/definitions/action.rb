require 'request_params_validation/definitions/request'

module RequestParamsValidation
  module Definitions
    class Action
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def request
        if block_given?
          @request = Request.new

          yield @request
        else
          @request
        end
      end
    end
  end
end
