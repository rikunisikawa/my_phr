FactoryBot.define do
  factory :health_log do
    association :user
    logged_on { Date.current }
    mood { 5 }
    stress_level { 4 }
    fatigue_level { 3 }
    notes { "Feeling okay" }
    custom_fields { { "blood_pressure" => 120 } }

    trait :with_activity do
      after(:build) do |health_log|
        health_log.activity_logs << build(:activity_log, health_log: health_log)
      end
    end
  end
end
