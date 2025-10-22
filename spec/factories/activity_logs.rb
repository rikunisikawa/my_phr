FactoryBot.define do
  factory :activity_log do
    association :health_log
    activity_type { "walking" }
    duration_minutes { 30 }
    intensity { "moderate" }
    custom_fields { { "calories" => 120 } }
  end
end
