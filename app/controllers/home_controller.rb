class HomeController < ApplicationController
  def index
    @profile = current_user.profile
    @latest_record = current_user.health_logs.includes(:activity_logs).order(logged_on: :desc).first
    @weekly_summary = SummaryCalculator.new(user: current_user, period: "weekly").call
  rescue ArgumentError
    @weekly_summary = nil
  end
end
