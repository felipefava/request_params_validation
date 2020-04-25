Rails.application.routes.draw do
  post 'dummy', to: 'application#dummy', as: :dummy
end
