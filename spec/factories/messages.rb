FactoryBot.define do
  factory :message do
    association :mentorship_request
    association :user
    body { Faker::Lorem.sentence(word_count: 10) }

    # sent_at is set automatically by before_create callback
    # but we can override it for testing

    trait :sent do
      after(:create) do |message|
        message.update_column(:sent_at, Time.current) unless message.sent_at
      end
    end

    trait :read do
      after(:create) do |message|
        # Ensure sent_at is set and in the past
        sent_time = message.sent_at || 1.hour.ago
        message.update_column(:sent_at, sent_time) unless message.sent_at

        # read_at must be after created_at and sent_at
        read_time = [message.created_at, sent_time].max + 5.minutes
        message.update_column(:read_at, read_time)
      end
    end

    trait :unread do
      after(:create) do |message|
        message.update_column(:sent_at, 10.minutes.ago) unless message.sent_at
        message.update_column(:read_at, nil)
      end
    end

    trait :long_message do
      body { Faker::Lorem.paragraph(sentence_count: 10) }
    end

    trait :short_message do
      body { Faker::Lorem.words(number: 3).join(' ') }
    end
  end
end

