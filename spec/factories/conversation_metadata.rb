FactoryBot.define do
  factory :conversation_metadata do
    association :mentorship_request
    association :user
    typing { false }
    typing_updated_at { Time.current }
    
    trait :typing do
      typing { true }
      typing_updated_at { Time.current }
    end
    
    trait :not_typing do
      typing { false }
      typing_updated_at { 1.minute.ago }
    end
    
    trait :stale do
      typing { true }
      typing_updated_at { 10.minutes.ago }
    end
  end
end

