require 'request_params_validation/params/constants'
require 'request_params_validation/params/validator'

module RequestParamsValidation
  module Params
    include Constants

    def self.validate!(definition, params)
      definition.each do |param_definition|
        validate_and_coerce_param(param_definition, params)
      end

      params
    end

    def self.filter!(definition, params)
      extra_keys = [:controller, :action] # Keys added by Rails

      filter_params(definition, params, extra_keys).tap do |params|
        params.permit! if params.is_a?(ActionController::Parameters)
      end
    end

    def self.validate_and_coerce_param(param_definition, params)
      key = param_definition.key
      value = params[key]

      value = Validator.new(param_definition, value).validate_and_coerce

      params[key] = value
    end
    private_class_method :validate_and_coerce_param

    def self.filter_params(definition, params, extra_keys = [])
      return unless params
      return params if definition.empty?

      params_keys = definition.map do |param_definition|
        key = param_definition.key

        if param_definition.sub_definition
          filter_params(param_definition.sub_definition, params[key])
        end

        key
      end.compact

      params_keys += extra_keys

      if params.is_a?(Array)
        params.map { |param| param.slice!(*params_keys) }
      else
        params.slice!(*params_keys)
      end

      params
    end
    private_class_method :filter_params
  end
end
