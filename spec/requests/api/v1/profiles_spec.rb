require "rails_helper"

RSpec.describe "Api::V1::Profiles", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /api/v1/profile" do
    it "returns the current profile" do
      create(:profile, user: user, age: 30)

      get "/api/v1/profile"

      expect(response).to have_http_status(:ok)
      expect(response_json).to include("age" => 30)
    end
  end

  describe "POST /api/v1/profile" do
    it "creates a profile" do
      post "/api/v1/profile", params: {
        profile: {
          age: 28,
          height_cm: 172.5,
          weight_kg: 68.2,
          custom_fields: { blood_type: "A" }
        }
      }

      expect(response).to have_http_status(:created)
      expect(user.reload.profile).to have_attributes(age: 28, height_cm: 172.5, weight_kg: 68.2)
    end
  end

  describe "PUT /api/v1/profile" do
    it "updates the profile" do
      profile = create(:profile, user: user, age: 25)

      put "/api/v1/profile", params: { profile: { age: 26 } }

      expect(response).to have_http_status(:ok)
      expect(profile.reload.age).to eq(26)
    end
  end
end
