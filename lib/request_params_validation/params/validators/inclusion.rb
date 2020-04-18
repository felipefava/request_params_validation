module RequestParamsValidation
  module Params
    module Validators
      module Inclusion
        def validate_inclusion!
          include_in = param.inclusion.in

          unless include_in.include?(value)
            raise_error(
              :on_invalid_parameter_inclusion,
              include_in: include_in,
              details: param.inclusion.message || default_invalid_inclusion_message(include_in)
            )
          end
        end

        def default_invalid_inclusion_message
          if param.element_of_array?
            "All elements of the array should have a value in #{include_in}"
          else
            "Value should be in #{include_in}"
          end
        end
      end
    end
  end
end
