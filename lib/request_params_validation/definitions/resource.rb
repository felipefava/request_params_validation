require 'request_params_validation/definitions/action'
require 'request_params_validation/exceptions/definitions_errors'

module RequestParamsValidation
  module Definitions
    class Resource
      attr_reader :name, :actions

      def initialize(name)
        @name = name
        @actions = {}
      end

      def action(action_name, &block)
        unless block_given?
          raise DefinitionArgumentError.new("Expecting block for action '#{action_name}'")
        end

        action = Action.new(action_name.to_s)

        action.instance_eval(&block)

        @actions[action_name.to_s] = action
      rescue DefinitionArgumentError => e
        e.resource = name
        raise
      end
    end
  end
end
