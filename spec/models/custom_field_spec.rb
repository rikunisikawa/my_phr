require "rails_helper"

RSpec.describe CustomField, type: :model do
  let(:user) { create(:user) }

  it "is valid with default attributes" do
    field = build(:custom_field, user: user)
    expect(field).to be_valid
  end

  it "requires a name" do
    field = build(:custom_field, user: user, name: nil)
    expect(field).not_to be_valid
  end

  it "enforces field type inclusion" do
    field = build(:custom_field, user: user, field_type: "unknown")
    expect(field).not_to be_valid
  end

  it "rejects options for non-select fields" do
    field = build(:custom_field, user: user, field_type: "text", options: ["A"])
    expect(field).not_to be_valid
  end

  it "accepts options for select fields" do
    field = build(:custom_field, user: user, field_type: "select", options: ["A"])
    expect(field).to be_valid
  end

  it "requires options for select fields" do
    field = build(:custom_field, user: user, field_type: "select", options: [])
    expect(field).not_to be_valid
  end
end
