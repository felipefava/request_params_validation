Rails.application.routes.draw do
  mount RequestParamsValidation::Engine => "/request_params_validation"

  get 'dummy_action', to: 'application#dummy_action', as: :dummy_action
end
