module RequestParamsValidation
  module Params
    module Validators
      module Format
        def validate_format!
          regexp = param.format.regexp

          if value !~ regexp
            raise_error(
              :on_invalid_parameter_format,
              regexp: regexp,
              details: param.format.message || default_invalid_format_message
            )
          end
        end

        def default_invalid_format_message
          if param.element_of_array?
            'An element has an invalid format'
          else
            'Value format is invalid'
          end
        end
      end
    end
  end
end
