module ApplicationHelper
  SUMMARY_PERIOD_OPTIONS = [
    ["日次", "daily"],
    ["短期推移", "short_term"],
    ["週次", "weekly"],
    ["月次", "monthly"]
  ].freeze

  SUMMARY_PERIOD_LABELS = SUMMARY_PERIOD_OPTIONS.to_h { |label, key| [key, label] }

  CUSTOM_FIELD_CATEGORY_LABELS = {
    "profile" => "プロフィール",
    "health" => "健康ログ",
    "activity" => "運動ログ"
  }.freeze

  CUSTOM_FIELD_TYPE_LABELS = {
    "text" => "テキスト",
    "number" => "数値",
    "boolean" => "チェックボックス",
    "select" => "選択式"
  }.freeze

  BOOLEAN_TYPE = ActiveModel::Type::Boolean.new

  def custom_field_category_label(category)
    CUSTOM_FIELD_CATEGORY_LABELS.fetch(category.to_s, category.to_s.titleize)
  end

  def custom_field_type_label(field_type)
    CUSTOM_FIELD_TYPE_LABELS.fetch(field_type.to_s, field_type.to_s)
  end

  def summary_period_options
    SUMMARY_PERIOD_OPTIONS
  end

  def summary_period_label(period)
    SUMMARY_PERIOD_LABELS.fetch(period.to_s, period.to_s)
  end

  def short_term_timeframe_options
    SummaryPeriodConfig.short_term_timeframe_options
  end

  def summary_bucket_range(bucket, period)
    return "-" if bucket.from.blank? || bucket.to.blank?

    case period.to_s
    when "short_term"
      from = ensure_time(bucket.from)
      to = ensure_time(bucket.to)
      "#{from.strftime('%Y-%m-%d %H:%M')} 〜 #{to.strftime('%H:%M')}"
    else
      "#{format_summary_value(bucket.from)} 〜 #{format_summary_value(bucket.to)}"
    end
  end

  def custom_field_value_present?(field, values)
    return false unless values.is_a?(Hash)

    values.key?(field.name) && (field.field_type == "boolean" || values[field.name].present?)
  end

  def display_custom_field_value(field, values)
    return nil unless values.is_a?(Hash) && values.key?(field.name)

    raw_value = values[field.name]

    case field.field_type
    when "boolean"
      BOOLEAN_TYPE.cast(raw_value) ? "はい" : "いいえ"
    when "number"
      numeric_value = begin
        Float(raw_value)
      rescue ArgumentError, TypeError
        nil
      end
      return numeric_value.to_i.to_s if numeric_value&.modulo(1)&.zero?

      numeric_value ? numeric_value.to_s : raw_value.to_s
    else
      raw_value.to_s
    end
  end

  private

  def ensure_time(value)
    case value
    when Time
      value.in_time_zone
    when Date
      value.in_time_zone
    else
      Time.zone.parse(value.to_s)
    end
  rescue ArgumentError, TypeError
    value.respond_to?(:to_time) ? value.to_time.in_time_zone : Time.zone.now
  end

  def format_summary_value(value)
    case value
    when Time
      value.in_time_zone.strftime("%Y-%m-%d %H:%M")
    when Date
      value.strftime("%Y-%m-%d")
    else
      value.to_s
    end
  end
end
