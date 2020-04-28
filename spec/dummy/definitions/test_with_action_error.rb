RequestParamsValidation.define do |application|
  application.action :action_with_no_block # this should fail, it has no block!
end
