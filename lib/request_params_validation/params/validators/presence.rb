module RequestParamsValidation
  module Params
    module Validators
      module Presence
        def validate_presence!
          not_present = param.allow_blank ? value.nil? : value.blank?

          raise_error(:on_missing_parameter) if not_present
        end
      end
    end
  end
end
