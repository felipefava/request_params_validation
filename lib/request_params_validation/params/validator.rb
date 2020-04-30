require 'request_params_validation/params/converter'

Dir[File.join(File.dirname(__FILE__), 'validators/**/*.rb')].each { |f| require f }

module RequestParamsValidation
  module Params
    class Validator

      Validators.constants(false).each do |validator|
        include Validators.const_get(validator)
      end

      attr_reader :param, :value, :original_value

      def initialize(param_definition, value)
        @param = param_definition
        @value = value
        @original_value = value
      end

      def validate_and_coerce
        validate_presence! if param.validate_presence?

        if value.blank? && param.has_default?
          @value = param.default
          return value
        end

        return value if value.nil?

        validate_type! if param.validate_type?

        case param.type
        when Params::ARRAY_TYPE
          iterate_array
        when Params::HASH_TYPE
          iterate_hash
        end

        @value = Params::Converter.coerce(param, value)

        validate_inclusion!         if param.validate_inclusion?
        validate_length!            if param.validate_length?
        validate_value!             if param.validate_value?
        validate_format!            if param.validate_format?
        validate_custom_validation! if param.validate_custom_validation?

        @value = Params::Converter.apply_transformation(param, value)
      end

      private

      def iterate_array
        value.map! do |element_value|
          self.class.new(param.elements, element_value).validate_and_coerce
        end
      end

      def iterate_hash
        Params.validate!(param.sub_definition, value) # recursion for the sub_definition
      end

      def raise_error(exception_type, options = {})
        options = options.merge(
          param_key: param.key,
          param_value: original_value,
          param_type: param.type
        )

        raise RequestParamsValidation.exceptions.send(exception_type).new(options)
      end
    end
  end
end
