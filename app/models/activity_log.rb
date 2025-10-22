class ActivityLog < ApplicationRecord
  belongs_to :health_log

  validates :activity_type, presence: true
  validates :duration_minutes, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :intensity, inclusion: { in: %w[low moderate high] }, allow_nil: true
  validate :custom_fields_must_be_object

  private

  def custom_fields_must_be_object
    return if custom_fields.blank?

    errors.add(:custom_fields, "must be a JSON object") unless custom_fields.is_a?(Hash)
  end
end
