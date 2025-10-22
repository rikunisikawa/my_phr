require "rails_helper"

RSpec.describe "HealthLogs API", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /api/v1/health_logs" do
    it "returns logs within the range" do
      create(:health_log, user: user, logged_on: Date.current - 2.days)
      create(:health_log, user: user, logged_on: Date.current)

      get api_v1_health_logs_path, params: { from: Date.current - 1.day, to: Date.current }

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(1)
    end
  end

  describe "POST /api/v1/health_logs" do
    it "creates a health log with activities" do
      params = {
        health_log: {
          logged_on: Date.current,
          mood: 7,
          activity_logs_attributes: [
            { activity_type: "running", duration_minutes: 20, intensity: "high" }
          ]
        }
      }

      post api_v1_health_logs_path, params: params

      expect(response).to have_http_status(:created)
      expect(user.health_logs.count).to eq(1)
      expect(user.health_logs.first.activity_logs.count).to eq(1)
    end
  end

  describe "PATCH /api/v1/health_logs/:id" do
    it "updates the health log" do
      log = create(:health_log, user: user, mood: 4)

      patch api_v1_health_log_path(log), params: { health_log: { mood: 8 } }

      expect(response).to have_http_status(:ok)
      expect(log.reload.mood).to eq(8)
    end
  end

  describe "DELETE /api/v1/health_logs/:id" do
    it "removes the health log" do
      log = create(:health_log, user: user)

      delete api_v1_health_log_path(log)

      expect(response).to have_http_status(:no_content)
      expect(user.health_logs).to be_empty
    end
  end
end
