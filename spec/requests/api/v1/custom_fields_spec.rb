require "rails_helper"

RSpec.describe "Api::V1::CustomFields", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  describe "GET /api/v1/custom_fields" do
    it "lists fields for the current user" do
      create(:custom_field, user: user, name: "blood_pressure")

      get "/api/v1/custom_fields"

      expect(response).to have_http_status(:ok)
      expect(response_json.first).to include("name" => "blood_pressure")
    end
  end

  describe "POST /api/v1/custom_fields" do
    it "creates a custom field" do
      post "/api/v1/custom_fields", params: {
        custom_field: {
          name: "Intensity",
          field_type: "select",
          category: "activity",
          options: %w[low medium high]
        }
      }

      expect(response).to have_http_status(:created)
      expect(user.custom_fields.count).to eq(1)
    end
  end

  describe "PATCH /api/v1/custom_fields/:id" do
    it "updates a custom field" do
      field = create(:custom_field, user: user, name: "Sleep", field_type: "number", category: "health")

      patch "/api/v1/custom_fields/#{field.id}", params: { custom_field: { name: "Sleep Time" } }

      expect(response).to have_http_status(:ok)
      expect(field.reload.name).to eq("Sleep Time")
    end
  end

  describe "DELETE /api/v1/custom_fields/:id" do
    it "removes a custom field" do
      field = create(:custom_field, user: user)

      delete "/api/v1/custom_fields/#{field.id}"

      expect(response).to have_http_status(:no_content)
      expect { field.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end
end
