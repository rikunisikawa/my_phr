require "rails_helper"

RSpec.describe ActivityLog, type: :model do
  let(:health_log) { create(:health_log) }

  it "is valid with default attributes" do
    activity = build(:activity_log, health_log: health_log)
    expect(activity).to be_valid
  end

  it "requires activity type" do
    activity = build(:activity_log, health_log: health_log, activity_type: nil)
    expect(activity).not_to be_valid
  end

  it "rejects invalid custom_fields" do
    activity = build(:activity_log, health_log: health_log, custom_fields: "invalid")
    expect(activity).not_to be_valid
  end

  it "requires duration to be a positive integer when present" do
    activity = build(:activity_log, health_log: health_log, duration_minutes: 0)
    expect(activity).not_to be_valid
  end
end
