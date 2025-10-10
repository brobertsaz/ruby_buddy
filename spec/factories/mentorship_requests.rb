FactoryBot.define do
  factory :mentorship_request do
    association :mentee, factory: [:user, :mentee]
    association :mentor, factory: [:user, :mentor]
    topic { Faker::Lorem.sentence(word_count: 5) }
    goals { Faker::Lorem.paragraph(sentence_count: 3) }
    preferred_times { "Weekday evenings" }
    status { :open }
    
    trait :open do
      status { :open }
      mentor { nil }
    end
    
    trait :accepted do
      status { :accepted }
      association :mentor, factory: [:user, :mentor]
    end
    
    trait :closed do
      status { :closed }
      association :mentor, factory: [:user, :mentor]
    end
    
    trait :with_messages do
      after(:create) do |request|
        create_list(:message, 3, mentorship_request: request, user: request.mentee)
        create_list(:message, 2, mentorship_request: request, user: request.mentor) if request.mentor
      end
    end
    
    trait :with_conversation do
      accepted
      
      after(:create) do |request|
        # Create a back-and-forth conversation
        create(:message, mentorship_request: request, user: request.mentee, body: "Hi! Thanks for accepting my request.", created_at: 2.hours.ago)
        create(:message, mentorship_request: request, user: request.mentor, body: "Happy to help! What would you like to work on first?", created_at: 1.hour.ago)
        create(:message, mentorship_request: request, user: request.mentee, body: "I'd love to learn more about Rails testing.", created_at: 30.minutes.ago)
      end
    end
  end
end

