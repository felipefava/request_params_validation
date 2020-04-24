require_relative 'boot'

require "rails"

# Pick the frameworks you want:
require "active_model/railtie"
require "action_controller/railtie"
require "action_view/railtie"

Bundler.require(*Rails.groups)

require "request_params_validation"

module Dummy
  class Application < Rails::Application
    config.load_defaults 5.2
  end
end
