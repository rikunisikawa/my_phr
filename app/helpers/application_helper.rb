module ApplicationHelper
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
end
