class SummaryCalculator
  PERIOD_UNITS = {
    "daily" => :day,
    "weekly" => :week,
    "monthly" => :month
  }.freeze

  Result = Struct.new(:period, :range, :buckets, keyword_init: true)
  Bucket = Struct.new(
    :label,
    :from,
    :to,
    :averages,
    :total_activity_duration,
    :activities_breakdown,
    :custom_fields,
    keyword_init: true
  )

  def initialize(user:, period:, start_date: nil, end_date: nil)
    @user = user
    @period = period
    @start_date = parse_date(start_date) || default_start_date
    @end_date = parse_date(end_date) || Date.current
    validate_period!
  end

  def call
    logs = @user.health_logs.between(@start_date, @end_date).includes(:activity_logs)
    grouped = logs.group_by { |log| bucket_start_for(log.logged_on) }

    buckets = grouped.sort_by { |start_date, _| start_date }.map do |bucket_start, bucket_logs|
      build_bucket(bucket_start, bucket_logs)
    end

    Result.new(
      period: @period,
      range: { from: @start_date, to: @end_date },
      buckets: buckets
    )
  end

  private

  def validate_period!
    raise ArgumentError, "Unsupported period: #{@period}" unless PERIOD_UNITS.key?(@period)
  end

  def parse_date(value)
    return value if value.is_a?(Date)

    Date.parse(value) if value.present?
  rescue ArgumentError
    nil
  end

  def default_start_date
    case @period
    when "daily"
      Date.current.beginning_of_week
    when "weekly"
      Date.current.beginning_of_month
    when "monthly"
      Date.current.beginning_of_year
    end
  end

  def bucket_start_for(date)
    case PERIOD_UNITS[@period]
    when :day
      date
    when :week
      date.beginning_of_week
    when :month
      date.beginning_of_month
    end
  end

  def bucket_end_for(start_date)
    case PERIOD_UNITS[@period]
    when :day
      start_date
    when :week
      start_date.end_of_week
    when :month
      start_date.end_of_month
    end
  end

  def build_bucket(bucket_start, logs)
    bucket_end = bucket_end_for(bucket_start)
    averages = compute_averages(logs)
    total_activity_duration = logs.sum { |log| total_activity_minutes(log) }
    activities_breakdown = build_activity_breakdown(logs)
    custom_fields = compute_custom_field_metrics(logs)

    Bucket.new(
      label: bucket_label(bucket_start),
      from: bucket_start,
      to: bucket_end,
      averages: averages,
      total_activity_duration: total_activity_duration,
      activities_breakdown: activities_breakdown,
      custom_fields: custom_fields
    )
  end

  def compute_averages(logs)
    {
      mood: average_for(logs.map(&:mood)),
      stress_level: average_for(logs.map(&:stress_level)),
      fatigue_level: average_for(logs.map(&:fatigue_level))
    }
  end

  def total_activity_minutes(log)
    log.activity_logs.sum { |activity| activity.duration_minutes.to_i }
  end

  def build_activity_breakdown(logs)
    breakdown = Hash.new(0)
    logs.each do |log|
      log.activity_logs.each do |activity|
        breakdown[activity.activity_type] += activity.duration_minutes.to_i
      end
    end
    breakdown
  end

  def compute_custom_field_metrics(logs)
    {
      health: compute_numeric_custom_fields(logs, :health),
      activity: compute_numeric_custom_fields(logs, :activity)
    }
  end

  def compute_numeric_custom_fields(logs, category)
    field_names = @user.custom_fields.where(category: category, field_type: "number").pluck(:name)

    values = field_names.index_with { { totals: 0.0, count: 0 } }

    case category
    when :health
      logs.each do |log|
        next if log.custom_fields.blank?

        field_names.each do |name|
          next unless log.custom_fields.key?(name)

          value = numeric_value(log.custom_fields[name])
          next if value.nil?

          values[name][:totals] += value
          values[name][:count] += 1
        end
      end
    when :activity
      logs.each do |log|
        log.activity_logs.each do |activity|
          next if activity.custom_fields.blank?

          field_names.each do |name|
            next unless activity.custom_fields.key?(name)

            value = numeric_value(activity.custom_fields[name])
            next if value.nil?

            values[name][:totals] += value
            values[name][:count] += 1
          end
        end
      end
    end

    values.transform_values do |data|
      count = data[:count]
      {
        total: data[:totals],
        average: count.positive? ? (data[:totals] / count) : nil
      }
    end
  end

  def numeric_value(value)
    Float(value)
  rescue ArgumentError, TypeError
    nil
  end

  def average_for(values)
    numeric_values = values.compact
    return nil if numeric_values.empty?

    numeric_values.sum.to_f / numeric_values.length
  end

  def bucket_label(start_date)
    case PERIOD_UNITS[@period]
    when :day
      start_date.strftime("%Y-%m-%d")
    when :week
      "Week of #{start_date.strftime('%Y-%m-%d')}"
    when :month
      start_date.strftime("%Y-%m")
    end
  end
end
