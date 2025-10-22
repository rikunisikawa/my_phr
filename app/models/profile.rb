class Profile < ApplicationRecord
  belongs_to :user

  validates :age, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 120 }, allow_nil: true
  validates :height_cm, numericality: { greater_than_or_equal_to: 50, less_than_or_equal_to: 250 }, allow_nil: true
  validates :weight_kg, numericality: { greater_than_or_equal_to: 10, less_than_or_equal_to: 300 }, allow_nil: true
  validate :custom_fields_must_be_object

  private

  def custom_fields_must_be_object
    return if custom_fields.blank?
    errors.add(:custom_fields, "must be a JSON object") unless custom_fields.is_a?(Hash)
  end
end
