class HealthLog < ApplicationRecord
  belongs_to :user
  has_many :activity_logs, dependent: :destroy

  accepts_nested_attributes_for :activity_logs, allow_destroy: true

  validates :recorded_at, presence: true
  validates :mood, :stress_level, :fatigue_level,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 },
            allow_nil: true
  validate :custom_fields_must_be_object

  scope :between, ->(from_value, to_value) {
    scope = all
    if (from_time = cast_time(from_value, upper_bound: false))
      scope = scope.where("recorded_at >= ?", from_time)
    end
    if (to_time = cast_time(to_value, upper_bound: true))
      scope = scope.where("recorded_at <= ?", to_time)
    end
    scope
  }

  def self.cast_time(value, upper_bound: false)
    case value
    when ActiveSupport::TimeWithZone
      value
    when Time
      value.in_time_zone
    when Date
      upper_bound ? value.end_of_day : value.beginning_of_day
    else
      return nil if value.blank?

      Time.zone.parse(value.to_s)
    end
  rescue ArgumentError, TypeError
    nil
  end

  private

  def custom_fields_must_be_object
    return if custom_fields.blank?
    unless custom_fields.is_a?(Hash)
      errors.add(:custom_fields, "must be a JSON object")
    end
  end
end
