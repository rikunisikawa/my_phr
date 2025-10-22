FactoryBot.define do
  factory :profile do
    association :user
    age { 30 }
    height_cm { 170.0 }
    weight_kg { 65.0 }
    custom_fields { { "blood_type" => "A" } }
  end
end
