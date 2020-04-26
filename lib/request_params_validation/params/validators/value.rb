module RequestParamsValidation
  module Params
    module Validators
      module Value
        def validate_value!
          min = param.value.min
          max = param.value.max

          if (min && value < min) || (max && value > max)
            raise_error(
              :on_invalid_parameter_value_size,
              min: min,
              max: max,
              details: param.value.message || default_invalid_value_message(min, max)
            )
          end
        end

        def default_invalid_value_message(min, max)
          message = if param.element_of_array?
                      'All elements of the array should have a value'
                    else
                      'Value should be'
                    end

          if min && max
            "#{message} between #{min} and #{max}"
          elsif min
            "#{message} greater or equal than #{min}"
          else
            "#{message} less or equal than #{max}"
          end
        end
      end
    end
  end
end
