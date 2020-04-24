class ApplicationController < ActionController::Base
  def dummy_action
    render json: { status: :success }
  end
end
