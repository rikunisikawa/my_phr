class HealthLog < ApplicationRecord
  belongs_to :user
  has_many :activity_logs, dependent: :destroy

  accepts_nested_attributes_for :activity_logs, allow_destroy: true

  validates :logged_on, presence: true
  validates :mood, :stress_level, :fatigue_level,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 10 },
            allow_nil: true
  validate :custom_fields_must_be_object

  scope :between, ->(from_date, to_date) {
    scope = all
    scope = scope.where("logged_on >= ?", from_date) if from_date.present?
    scope = scope.where("logged_on <= ?", to_date) if to_date.present?
    scope
  }

  private

  def custom_fields_must_be_object
    return if custom_fields.blank?
    unless custom_fields.is_a?(Hash)
      errors.add(:custom_fields, "must be a JSON object")
    end
  end
end
