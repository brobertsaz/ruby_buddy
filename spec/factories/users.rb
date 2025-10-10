FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    onboarding_completed { false }
    
    trait :onboarded do
      onboarding_completed { true }
    end
    
    trait :mentee do
      role { "mentee" }
      onboarding_completed { true }
      
      after(:create) do |user|
        create(:profile, :mentee, user: user) unless user.profile
      end
    end
    
    trait :mentor do
      role { "mentor" }
      onboarding_completed { true }
      
      after(:create) do |user|
        create(:profile, :mentor, user: user) unless user.profile
      end
    end
    
    trait :both do
      role { "both" }
      onboarding_completed { true }
      
      after(:create) do |user|
        create(:profile, :both, user: user) unless user.profile
      end
    end
    
    trait :with_profile do
      after(:create) do |user|
        create(:profile, user: user) unless user.profile
      end
    end
  end
end

