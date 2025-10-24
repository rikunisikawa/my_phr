require "rails_helper"

RSpec.describe "Api::V1::Summaries", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
    health_log = create(:health_log, :with_activity, user: user, recorded_at: Time.zone.now.change(sec: 0), mood: 70, stress_level: 45, fatigue_level: 30)
    health_log.activity_logs.first.update!(duration_minutes: 45)
  end

  it "returns summary data" do
    get "/api/v1/summaries", params: { period: "daily" }

    expect(response).to have_http_status(:ok)
    expect(response_json).to include("period" => "daily")
  end

  it "returns error for invalid period" do
    get "/api/v1/summaries", params: { period: "yearly" }

    expect(response).to have_http_status(:unprocessable_entity)
    expect(response_json["errors"]).to be_present
  end
end
