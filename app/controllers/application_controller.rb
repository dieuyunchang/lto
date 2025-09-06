class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern  # Rails 6.1 doesn't have this

  # API base controller
  class Api::V1::BaseController < ApplicationController
    protect_from_forgery with: :null_session
    before_action :set_default_response_format

    private

    def set_default_response_format
      request.format = :json
    end

    def render_error(message, status = :unprocessable_entity)
      render json: { error: message }, status: status
    end

    def render_success(data, message = nil)
      response = { data: data }
      response[:message] = message if message
      render json: response
    end
  end
end
