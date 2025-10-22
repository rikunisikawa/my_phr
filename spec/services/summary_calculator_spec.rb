require "rails_helper"

RSpec.describe SummaryCalculator do
  let(:user) { create(:user) }
  let!(:health_log) do
    create(:health_log, :with_activity, user: user, logged_on: Date.current, mood: 6, stress_level: 4, fatigue_level: 3)
  end
  let!(:health_log_previous_week) do
    create(:health_log, :with_activity, user: user, logged_on: Date.current - 7.days, mood: 4, stress_level: 5, fatigue_level: 6)
  end
  let!(:health_field) { create(:custom_field, :number_health, user: user, name: "blood_pressure") }
  let!(:activity_field) { create(:custom_field, :number_activity, user: user, name: "calories") }

  before do
    health_log.custom_fields = { "blood_pressure" => 120 }
    health_log.save!
    health_log.activity_logs.first.update!(custom_fields: { "calories" => 200 })

    health_log_previous_week.custom_fields = { "blood_pressure" => 110 }
    health_log_previous_week.save!
    health_log_previous_week.activity_logs.first.update!(custom_fields: { "calories" => 150 })
  end

  it "returns buckets for the specified period" do
    result = described_class.new(user: user, period: "weekly").call

    expect(result.period).to eq("weekly")
    expect(result.buckets.size).to be >= 1
    expect(result.buckets.first.averages).to include(:mood, :stress_level, :fatigue_level)
  end

  it "computes numeric custom field summaries" do
    result = described_class.new(user: user, period: "weekly").call

    totals = result.buckets.last.custom_fields[:health]["blood_pressure"][:total]
    expect(totals).to be > 0
  end

  it "raises error for unsupported period" do
    expect { described_class.new(user: user, period: "yearly").call }.to raise_error(ArgumentError)
  end
end
