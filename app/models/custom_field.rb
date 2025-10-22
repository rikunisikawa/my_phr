class CustomField < ApplicationRecord
  attr_accessor :options_text

  FIELD_TYPES = %w[text number boolean select].freeze
  CATEGORIES = %w[profile health activity].freeze

  belongs_to :user

  validates :name, presence: true, length: { maximum: 30 }
  validates :name, uniqueness: { scope: %i[user_id category] }
  validates :field_type, inclusion: { in: FIELD_TYPES }
  validates :category, inclusion: { in: CATEGORIES }
  validate :options_must_match_field_type

  scope :for_category, ->(category) { where(category: category) }

  private

  def options_must_match_field_type
    if options.blank?
      errors.add(:options, "must be present for select field type") if field_type == "select"
      return
    end

    unless options.is_a?(Array)
      errors.add(:options, "must be an array when provided")
      return
    end

    if field_type != "select"
      errors.add(:options, "are only allowed for select field type")
      return
    end

    unless options.all? { |entry| entry.is_a?(String) && entry.present? }
      errors.add(:options, "must contain non-empty strings")
    end
  end
end
