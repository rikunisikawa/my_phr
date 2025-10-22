require "rails_helper"

RSpec.describe HealthLog, type: :model do
  let(:user) { create(:user) }

  it "is valid with default attributes" do
    log = build(:health_log, user: user)
    expect(log).to be_valid
  end

  it "requires logged_on" do
    log = build(:health_log, user: user, logged_on: nil)
    expect(log).not_to be_valid
  end

  it "rejects invalid custom_fields" do
    log = build(:health_log, user: user, custom_fields: "invalid")
    expect(log).not_to be_valid
  end

  it "requires scores to be within 1 to 5" do
    log = build(:health_log, user: user, mood: 6)
    expect(log).not_to be_valid
  end

  it "filters by date range" do
    older = create(:health_log, user: user, logged_on: Date.current - 5.days)
    newer = create(:health_log, user: user, logged_on: Date.current)

    results = described_class.between(Date.current - 1.day, Date.current + 1.day)

    expect(results).to include(newer)
    expect(results).not_to include(older)
  end
end
