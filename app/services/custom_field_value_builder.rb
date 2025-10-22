class CustomFieldValueBuilder
  def initialize(definitions)
    @definitions = Array(definitions)
    @definition_map = @definitions.index_by { |definition| definition.id.to_s }
    @boolean_type = ActiveModel::Type::Boolean.new
  end

  def build(raw_values)
    return {} if raw_values.blank?

    raw_values.each_with_object({}) do |(id, value), result|
      field = @definition_map[id.to_s]
      next unless field

      casted_value = cast_value(field, extract_value(value))
      next if skip_value?(field, casted_value)

      result[field.name] = casted_value
    end
  end

  private

  def cast_value(field, raw_value)
    case field.field_type
    when "number"
      cast_number(raw_value)
    when "boolean"
      @boolean_type.cast(raw_value)
    when "select"
      cast_select(field, raw_value)
    else
      raw_value.is_a?(String) ? raw_value.strip.presence : raw_value.presence
    end
  end

  def cast_number(raw_value)
    return nil if raw_value.blank?

    Float(raw_value)
  rescue ArgumentError, TypeError
    nil
  end

  def skip_value?(field, value)
    return false if field.field_type == "boolean"

    value.blank?
  end

  def cast_select(field, raw_value)
    return nil if raw_value.blank?

    value = raw_value.to_s.strip
    return value if field.options.to_a.include?(value)

    nil
  end

  def extract_value(value)
    value.is_a?(Array) ? value.last : value
  end
end
