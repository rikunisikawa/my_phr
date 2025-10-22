require "rails_helper"

RSpec.describe Profile, type: :model do
  subject(:profile) { build(:profile) }

  it "belongs to a user" do
    expect(profile.user).to be_present
  end

  it "is valid with default attributes" do
    expect(profile).to be_valid
  end

  it "rejects negative age" do
    profile.age = -1
    expect(profile).not_to be_valid
  end

  it "rejects non-hash custom_fields" do
    profile.custom_fields = [1, 2, 3]
    expect(profile).not_to be_valid
    expect(profile.errors[:custom_fields]).to include("must be a JSON object")
  end
end
