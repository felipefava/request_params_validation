class ApplicationController < ActionController::Base
  # For testing purpose
  mattr_accessor :dummy_params_definition
  self.dummy_params_definition = -> (params) {}

  before_action :validate_params!

  rescue_from RequestParamsValidation::RequestParamError do |exception|
    render status: :unprocessable_entity,
           json: { status: :error, key: exception.class.to_s, message: exception.message }
  end

  def dummy
    render json: { status: :success }
  end
end
