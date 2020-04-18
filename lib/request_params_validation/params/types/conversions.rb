module RequestParamsValidation
  module Params
    module Types
      module Conversions
        def convert_to_string(value)
          String(value)
        end

        def convert_to_integer(value)
          Integer(value)
        end

        def convert_to_decimal(value, precision)
          precision = precision || RequestParamsValidation.formats.decimal_precision

          value = Float(value)

          value = value.round(precision) if precision

          value
        end

        def convert_to_boolean(value)
          Params::BOOLEAN_TRUE_VALUES.include?(value)
        end

        def convert_to_date(value, format)
          format = format || RequestParamsValidation.formats.date

          format ? Date.strptime(value, format) : Date.parse(value)
        end

        def convert_to_datetime(value)
          format = format || RequestParamsValidation.formats.datetime

          format ? DateTime.strptime(value, format) : DateTime.parse(value)
        end
      end
    end
  end
end
