module RequestParamsValidation
  module Params
    module Constants
      HASH_TYPE     = :hash
      ARRAY_TYPE    = :array
      STRING_TYPE   = :string
      INTEGER_TYPE  = :integer
      DECIMAL_TYPE  = :decimal
      BOOLEAN_TYPE  = :boolean
      DATE_TYPE     = :date
      DATETIME_TYPE = :datetime
      EMAIL_TYPE    = :email

      INTEGER_REGEXP = /^[+-]?([1-9]\d*|0)$/
      DECIMAL_REGEXP = /^[+-]?([1-9]\d*|0)(\.[0-9]+)?$/
      EMAIL_REGEXP   = /\A[a-zA-Z0-9.!\#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\z/

      BOOLEAN_TRUE_VALUES  = [true, 'true']   + RequestParamsValidation.extends.boolean_true_values
      BOOLEAN_FALSE_VALUES = [false, 'false'] + RequestParamsValidation.extends.boolean_false_values
    end
  end
end
