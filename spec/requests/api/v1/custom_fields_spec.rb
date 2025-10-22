require "rails_helper"

RSpec.describe "CustomFields API", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /api/v1/custom_fields" do
    it "returns fields for the user" do
      create_list(:custom_field, 2, user: user)

      get api_v1_custom_fields_path

      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body).size).to eq(2)
    end
  end

  describe "POST /api/v1/custom_fields" do
    it "creates a custom field" do
      params = { custom_field: { name: "blood_pressure", field_type: "number", category: "health" } }

      post api_v1_custom_fields_path, params: params

      expect(response).to have_http_status(:created)
      expect(user.reload.custom_fields.count).to eq(1)
    end
  end

  describe "PATCH /api/v1/custom_fields/:id" do
    it "updates the custom field" do
      field = create(:custom_field, user: user, name: "Mood", field_type: "text", category: "health")

      patch api_v1_custom_field_path(field), params: { custom_field: { name: "Updated Mood" } }

      expect(response).to have_http_status(:ok)
      expect(field.reload.name).to eq("Updated Mood")
    end
  end

  describe "DELETE /api/v1/custom_fields/:id" do
    it "removes the custom field" do
      field = create(:custom_field, user: user)

      delete api_v1_custom_field_path(field)

      expect(response).to have_http_status(:no_content)
      expect(user.custom_fields).to be_empty
    end
  end
end
