require "rails_helper"

RSpec.describe HealthLog, type: :model do
  let(:user) { create(:user) }

  it "is valid with default attributes" do
    log = build(:health_log, user: user)
    expect(log).to be_valid
  end

  it "requires recorded_at" do
    log = build(:health_log, user: user, recorded_at: nil)
    expect(log).not_to be_valid
  end

  it "rejects invalid custom_fields" do
    log = build(:health_log, user: user, custom_fields: "invalid")
    expect(log).not_to be_valid
  end

  it "requires scores to be within 0 to 100" do
    log = build(:health_log, user: user, mood: 120)
    expect(log).not_to be_valid
  end

  it "filters by datetime range" do
    older = create(:health_log, user: user, recorded_at: 5.days.ago)
    newer = create(:health_log, user: user, recorded_at: Time.zone.now)

    results = described_class.between(1.day.ago, 1.day.from_now)

    expect(results).to include(newer)
    expect(results).not_to include(older)
  end
end
