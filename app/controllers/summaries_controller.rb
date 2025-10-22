class SummariesController < ApplicationController
  PERIODS = %w[daily weekly monthly].freeze

  def index
    @period = PERIODS.include?(params[:period]) ? params[:period] : "daily"
    @summary = SummaryCalculator.new(
      user: current_user,
      period: @period,
      start_date: params[:from],
      end_date: params[:to]
    ).call
  rescue ArgumentError => e
    flash.now[:alert] = e.message
    @summary = nil
  end
end
