class SummariesController < ApplicationController
  PERIODS = %w[daily short_term weekly monthly].freeze
  LEGACY_PERIOD_ALIASES = { "hourly" => "short_term" }.freeze
  SHORT_TERM_DEFAULT_HOURS = 3

  def index
    @period = normalize_period(params[:period])

    if @period == "short_term"
      @timeframe_hours = normalize_timeframe_hours(params[:timeframe_hours])
      @short_term_end_time = parse_end_time(params[:to]) || Time.current
      summary_start = calculate_short_term_start(@short_term_end_time, @timeframe_hours)
      summary_end = @short_term_end_time
    else
      @timeframe_hours = nil
      @short_term_end_time = nil
      summary_start = params[:from]
      summary_end = params[:to]
    end

    @summary = SummaryCalculator.new(
      user: current_user,
      period: @period,
      start_date: summary_start,
      end_date: summary_end
    ).call

    environment_metrics = EnvironmentMetricsLoader.new.call
    @chart_data = build_chart_data(@summary, environment_metrics.samples)
    @environment_data_error = environment_metrics.error
  rescue ArgumentError => e
    flash.now[:alert] = e.message
    @summary = nil
    @chart_data = nil
  end

  private

  def normalize_period(requested_period)
    period = requested_period.presence
    period = LEGACY_PERIOD_ALIASES[period] if period && LEGACY_PERIOD_ALIASES.key?(period)
    PERIODS.include?(period) ? period : "daily"
  end

  def normalize_timeframe_hours(raw_value)
    hours = raw_value.to_i
    allowed = SummaryPeriodConfig::SHORT_TERM_TIMEFRAME_HOURS
    return hours if allowed.include?(hours)

    SHORT_TERM_DEFAULT_HOURS
  end

  def parse_end_time(value)
    case value
    when ActiveSupport::TimeWithZone, Time
      value.in_time_zone
    when Date
      value.end_of_day.in_time_zone
    else
      Time.zone.parse(value.to_s) if value.present?
    end
  rescue ArgumentError
    nil
  end

  def calculate_short_term_start(end_time, hours)
    return end_time - (hours - 1).hours if hours.positive?

    end_time
  end

  def build_chart_data(summary, sensor_samples)
    return nil unless summary&.buckets&.any?

    {
      columns: [
        { type: "string", label: "期間" },
        { type: "number", label: "気分" },
        { type: "number", label: "ストレス" },
        { type: "number", label: "疲労" },
        { type: "number", label: "運動時間(分)" },
        { type: "number", label: "温度 (°C)" },
        { type: "number", label: "湿度 (%)" },
        { type: "number", label: "CO2 (ppm)" }
      ],
      rows: summary.buckets.map do |bucket|
        sensor_data = sensor_averages_for(bucket, sensor_samples)
        [
          bucket.label,
          bucket.averages[:mood]&.round(2),
          bucket.averages[:stress_level]&.round(2),
          bucket.averages[:fatigue_level]&.round(2),
          bucket.total_activity_duration.to_i,
          sensor_data[:temperature],
          sensor_data[:humidity],
          sensor_data[:co2]
        ]
      end
    }
  end

  def sensor_averages_for(bucket, samples)
    return empty_sensor_data if samples.blank?

    start_time, end_time = bucket_time_range(bucket)
    return empty_sensor_data unless start_time && end_time

    relevant = samples.select do |sample|
      timestamp = sample[:timestamp]
      timestamp && timestamp >= start_time && timestamp <= end_time
    end

    return empty_sensor_data if relevant.empty?

    {
      temperature: average_numeric(relevant.map { |sample| sample[:temperature] })&.round(2),
      humidity: average_numeric(relevant.map { |sample| sample[:humidity] })&.round(2),
      co2: average_numeric(relevant.map { |sample| sample[:co2] })&.round(2)
    }
  end

  def bucket_time_range(bucket)
    start_time = HealthLog.cast_time(bucket.from, upper_bound: false) || parse_end_time(bucket.from)
    end_time = HealthLog.cast_time(bucket.to, upper_bound: true) || parse_end_time(bucket.to)
    [start_time, end_time]
  end

  def average_numeric(values)
    numeric_values = values.compact
    return nil if numeric_values.empty?

    numeric_values.sum.to_f / numeric_values.length
  end

  def empty_sensor_data
    { temperature: nil, humidity: nil, co2: nil }
  end
end
