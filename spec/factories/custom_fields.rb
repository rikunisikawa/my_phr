FactoryBot.define do
  factory :custom_field do
    association :user
    sequence(:name) { |n| "custom_field_#{n}" }
    field_type { "text" }
    category { "profile" }
    options { [] }

    trait :number_health do
      field_type { "number" }
      category { "health" }
    end

    trait :number_activity do
      field_type { "number" }
      category { "activity" }
    end
  end
end
