Rails.application.routes.draw do
  mount RequestParamsValidation::Engine => "/request_params_validation"

  get 'dummy', to: 'application#dummy', as: :dummy
end
