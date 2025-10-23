class SummariesController < ApplicationController
  PERIODS = %w[daily hourly weekly monthly].freeze

  def index
    @period = PERIODS.include?(params[:period]) ? params[:period] : "daily"
    @summary = SummaryCalculator.new(
      user: current_user,
      period: @period,
      start_date: params[:from],
      end_date: params[:to]
    ).call
    @chart_data = build_chart_data(@summary)
  rescue ArgumentError => e
    flash.now[:alert] = e.message
    @summary = nil
    @chart_data = nil
  end

  private

  def build_chart_data(summary)
    return nil unless summary&.buckets&.any?

    {
      columns: [
        { type: "string", label: "期間" },
        { type: "number", label: "気分" },
        { type: "number", label: "ストレス" },
        { type: "number", label: "疲労" },
        { type: "number", label: "運動時間(分)" }
      ],
      rows: summary.buckets.map do |bucket|
        [
          bucket.label,
          bucket.averages[:mood]&.round(2),
          bucket.averages[:stress_level]&.round(2),
          bucket.averages[:fatigue_level]&.round(2),
          bucket.total_activity_duration.to_i
        ]
      end
    }
  end
end
