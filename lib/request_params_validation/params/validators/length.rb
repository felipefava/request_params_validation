module RequestParamsValidation
  module Params
    module Validators
      module Length
        def validate_length!
          min = param.length.min
          max = param.length.max

          if (min && value.length < min) || (max && value.length > max)
            raise_error(
              :on_invalid_parameter_length,
              min: min,
              max: max,
              details: param.length.message || default_invalid_length_message(min, max)
            )
          end
        end

        def default_invalid_length_message(min, max)
          message = if param.element_of_array?
                      'All elements should have a length'
                    else
                      'Length shoud be'
                    end

          if min && max
            min == max ? "#{message} equal to #{max}" : "#{message} between #{min} and #{max}"
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
