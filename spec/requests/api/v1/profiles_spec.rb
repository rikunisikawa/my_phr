require "rails_helper"

RSpec.describe "Profiles API", type: :request do
  let(:user) { create(:user) }

  before do
    sign_in user
  end

  describe "GET /api/v1/profile" do
    it "returns the user's profile" do
      create(:profile, user: user, age: 32)

      get api_v1_profile_path

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)["age"]).to eq(32)
    end
  end

  describe "POST /api/v1/profile" do
    it "creates a profile" do
      params = { profile: { age: 30, height_cm: 170, weight_kg: 65 } }

      post api_v1_profile_path, params: params

      expect(response).to have_http_status(:created)
      expect(user.reload.profile.age).to eq(30)
    end
  end

  describe "PATCH /api/v1/profile" do
    it "updates the profile" do
      create(:profile, user: user, age: 30)

      patch api_v1_profile_path, params: { profile: { age: 31 } }

      expect(response).to have_http_status(:ok)
      expect(user.reload.profile.age).to eq(31)
    end
  end
end
