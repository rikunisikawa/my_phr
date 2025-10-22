require "rails_helper"

RSpec.describe "Api::V1::HealthLogs", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /api/v1/health_logs" do
    it "filters by date range" do
      create(:health_log, user: user, logged_on: Date.current - 2.days)
      recent = create(:health_log, user: user, logged_on: Date.current)

      get "/api/v1/health_logs", params: { from: Date.current - 1.day, to: Date.current }

      expect(response).to have_http_status(:ok)
      ids = response_json.map { |log| log["id"] }
      expect(ids).to include(recent.id)
    end
  end

  describe "POST /api/v1/health_logs" do
    it "creates a health log with activities" do
      post "/api/v1/health_logs", params: {
        health_log: {
          logged_on: Date.current,
          mood: 3,
          stress_level: 2,
          fatigue_level: 4,
          notes: "Feeling good",
          custom_fields: { sleep_hours: 7 },
          activity_logs_attributes: [
            {
              activity_type: "Running",
              duration_minutes: 30,
              intensity: "high",
              custom_fields: { calories: 250 }
            }
          ]
        }
      }

      expect(response).to have_http_status(:created)
      expect(user.health_logs.count).to eq(1)
      expect(user.health_logs.first.activity_logs.count).to eq(1)
    end
  end

  describe "PUT /api/v1/health_logs/:id" do
    it "updates a health log" do
      log = create(:health_log, user: user, mood: 2)

      put "/api/v1/health_logs/#{log.id}", params: { health_log: { mood: 4 } }

      expect(response).to have_http_status(:ok)
      expect(log.reload.mood).to eq(4)
    end
  end

  describe "DELETE /api/v1/health_logs/:id" do
    it "deletes a health log" do
      log = create(:health_log, user: user)

      delete "/api/v1/health_logs/#{log.id}"

      expect(response).to have_http_status(:no_content)
      expect { log.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
