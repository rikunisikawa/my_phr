class ApplicationController < ActionController::Base
  include Devise::Controllers::Helpers

  protect_from_forgery with: :null_session
  before_action :authenticate_user!
end
