module RequestParamsValidation
  module Params
    module Types
      module Validations
        def valid_array?(value)
          value.is_a?(Array)
        end

        def valid_hash?(value)
          value.is_a?(Hash) || value.is_a?(ActionController::Parameters)
        rescue NameError # For older versions of Rails
          false
        end

        def valid_string?(_value)
          true
        end

        def valid_integer?(value)
          !!(value.to_s =~ Params::INTEGER_REGEXP)
        end

        def valid_decimal?(value)
          !!(value.to_s =~ Params::DECIMAL_REGEXP)
        end

        def valid_email?(value)
          !!(value =~ Params::EMAIL_REGEXP)
        end

        def valid_boolean?(value)
          (Params::BOOLEAN_TRUE_VALUES + Params::BOOLEAN_FALSE_VALUES).include?(value)
        end

        def valid_date?(value, format)
          format = format || RequestParamsValidation.formats.date

          format ? Date.strptime(value, format) : Date.parse(value)

          true
        rescue ArgumentError, TypeError
          false
        end

        def valid_datetime?(value, format)
          format = format || RequestParamsValidation.formats.datetime

          format ? DateTime.strptime(value, format) : DateTime.parse(value)

          true
        rescue ArgumentError, TypeError
          false
        end
      end
    end
  end
end
