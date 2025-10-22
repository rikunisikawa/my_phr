class CustomField < ApplicationRecord
  FIELD_TYPES = %w[text number boolean select].freeze
  CATEGORIES = %w[profile health activity].freeze

  belongs_to :user

  validates :name, presence: true
  validates :field_type, inclusion: { in: FIELD_TYPES }
  validates :category, inclusion: { in: CATEGORIES }
  validate :options_must_match_field_type

  scope :for_category, ->(category) { where(category: category) }

  private

  def options_must_match_field_type
    return if options.blank?
    unless options.is_a?(Array)
      errors.add(:options, "must be an array when provided")
      return
    end

    if field_type != "select" && options.present?
      errors.add(:options, "are only allowed for select field type")
    end
  end
end
