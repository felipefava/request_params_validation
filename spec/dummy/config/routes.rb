Rails.application.routes.draw do
  post 'dummy', to: 'application#dummy', as: :dummy
  post 'dummy_with_no_definition', to: 'application#dummy_with_no_definition', as: :dummy_with_no_definition
end
