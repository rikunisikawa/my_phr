require "rails_helper"

RSpec.describe "Summaries API", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
    create(:custom_field, :number_health, user: user, name: "blood_pressure")
    create(:health_log, :with_activity, user: user, logged_on: Date.current, mood: 6, stress_level: 4, fatigue_level: 3)
  end

  it "returns summary data" do
    get api_v1_summaries_path, params: { period: "daily" }

    expect(response).to have_http_status(:ok)
    body = JSON.parse(response.body)
    expect(body["buckets"]).not_to be_empty
  end

  it "returns error for unsupported period" do
    get api_v1_summaries_path, params: { period: "invalid" }

    expect(response).to have_http_status(:unprocessable_entity)
  end
end
