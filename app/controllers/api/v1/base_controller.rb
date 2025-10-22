module Api
  module V1
    class BaseController < ApplicationController
      protect_from_forgery with: :null_session
      skip_before_action :verify_authenticity_token
      before_action :authenticate_user!
      respond_to :json
      before_action :ensure_json_request

      private

      def ensure_json_request
        request.format = :json
      end
    end
  end
end
