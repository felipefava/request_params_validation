require 'request_params_validation/params/types/conversions'

module RequestParamsValidation
  module Params
    module Converter
      extend Params::Types::Conversions

      def self.coerce(param, value)
        type = param.type

        method_name = "convert_to_#{type}"

        return value unless self.respond_to?(method_name)

        if [Params::DATE_TYPE, Params::DATETIME_TYPE].include?(type)
          self.send(method_name, value, param.format.try(:strptime))
        elsif type == Params::DECIMAL_TYPE
          self.send(method_name, value, param.decimal_precision)
        else
          self.send(method_name, value)
        end
      end

      def self.apply_transformation(param, value)
        transform = param.transform

        return value unless transform

        transform.respond_to?(:call) ? transform.call(value) : value.send(transform)
      end
    end
  end
end
