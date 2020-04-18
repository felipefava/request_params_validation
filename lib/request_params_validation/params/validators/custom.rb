module RequestParamsValidation
  module Params
    module Validators
      module Custom
        def validate_custom_validation!
          result = param.custom_validation.function.call(value)

          unless result
            raise_error(
              :on_invalid_parameter_custom_validation,
              details: param.custom_validation.message
            )
          end
        end
      end
    end
  end
end
