require "rails_helper"

RSpec.describe SummaryCalculator do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    travel_to(Time.zone.local(2024, 6, 1, 12, 0, 0)) { example.run }
  end

  let(:user) { create(:user) }
  let!(:health_log) do
    create(:health_log, :with_activity, user: user, recorded_at: Time.zone.now.change(sec: 0), mood: 85, stress_level: 40, fatigue_level: 25)
  end
  let!(:health_log_previous_week) do
    create(:health_log, :with_activity, user: user, recorded_at: 7.days.ago.change(sec: 0), mood: 60, stress_level: 70, fatigue_level: 55)
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

  it "groups logs by hour for the hourly period" do
    create(:health_log, user: user, recorded_at: Time.zone.now.change(hour: 9, min: 15), mood: 70, stress_level: 30, fatigue_level: 20)
    create(:health_log, user: user, recorded_at: Time.zone.now.change(hour: 9, min: 45), mood: 50, stress_level: 25, fatigue_level: 45)
    create(:health_log, user: user, recorded_at: Time.zone.now.change(hour: 18, min: 5), mood: 65, stress_level: 55, fatigue_level: 40)

    start_time = Time.zone.now.beginning_of_day
    end_time = Time.zone.now.end_of_day
    result = described_class.new(user: user, period: "short_term", start_date: start_time, end_date: end_time).call

    expect(result.period).to eq("short_term")
    expect(result.buckets.map(&:label)).to include("06/01 09:00", "06/01 18:00")

    morning_bucket = result.buckets.find { |bucket| bucket.label == "06/01 09:00" }
    expect(morning_bucket.total_activity_duration).to be >= 0
    expect(morning_bucket.averages[:mood]).to be_within(0.01).of(60.0)
  end

  it "accepts the legacy hourly identifier" do
    result = described_class.new(user: user, period: "hourly").call

    expect(result.period).to eq("hourly")
    expect(result.buckets).to be_an(Array)
  end
end
