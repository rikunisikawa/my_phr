class HomeController < ApplicationController
  def index
    @profile = current_user.profile
    @latest_record = current_user.health_logs.includes(:activity_logs).order(recorded_at: :desc).first
    @weekly_summary = SummaryCalculator.new(user: current_user, period: "weekly").call
    environment_metrics = EnvironmentMetricsLoader.new.call
    @environmental_samples = environment_metrics.samples
    @environmental_chart_data = environment_metrics.chart_data
    @environmental_source_file = environment_metrics.source_file
    @environmental_data_error = environment_metrics.error
  rescue ArgumentError
    @weekly_summary = nil
  end
end
