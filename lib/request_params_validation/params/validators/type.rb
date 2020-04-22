require 'request_params_validation/params/types/validations'

module RequestParamsValidation
  module Params
    module Validators
      module Type
        include Params::Types::Validations
        include RequestParamsValidation.extends.types if RequestParamsValidation.extends.types

        def validate_type!
          type = param.type

          method_name = "valid_#{type}?"

          unless self.respond_to?(method_name)
            raise UnsupportedTypeError.new(param_key: param.key, param_type: type)
          end

          valid = if [Params::DATE_TYPE, Params::DATETIME_TYPE].include?(type)
                    self.send(method_name, value, param.format.try(:strptime))
                  else
                    self.send(method_name, value)
                  end

          unless valid
            raise_error(
              :on_invalid_parameter_type,
              details: default_invalid_type_message(type)
            )
          end
        end

        def default_invalid_type_message(type)
          type = :object if type == Params::HASH_TYPE

          message = if param.element_of_array?
                      "All elements should be a valid #{type}"
                    else
                      "Value should be a valid #{type}"
                    end

          if [Params::DATE_TYPE, Params::DATETIME_TYPE].include?(type)
            format = param.format.try(:strptime) || RequestParamsValidation.formats.send(type)

            if format
              message = if param.format.try(:message)
                          param.format.message
                        else
                          "#{message} with the format #{format}"
                        end
            end
          end

          message
        end
      end
    end
  end
end
