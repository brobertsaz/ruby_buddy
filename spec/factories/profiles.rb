FactoryBot.define do
  factory :profile do
    association :user
    sequence(:name) { |n| Faker::Name.name }
    bio { Faker::Lorem.paragraph(sentence_count: 3) }
    years_experience { rand(0..20) }
    timezone { Faker::Address.time_zone }
    skills { "Ruby, Rails, JavaScript" }
    availability { "Weekday evenings, weekends" }
    github_url { Faker::Internet.url(host: 'github.com') }
    x_url { Faker::Internet.url(host: 'x.com') }
    website_url { Faker::Internet.url }
    mentor { false }
    mentee { false }
    
    trait :mentor do
      mentor { true }
      mentee { false }
      bio { "Experienced Ruby developer with #{years_experience} years of experience. Happy to help junior developers learn Rails!" }
      years_experience { rand(5..20) }
    end
    
    trait :mentee do
      mentor { false }
      mentee { true }
      bio { "Aspiring Ruby developer looking to learn from experienced mentors." }
      years_experience { rand(0..2) }
    end
    
    trait :both do
      mentor { true }
      mentee { true }
      bio { "Experienced developer who also loves learning new things. Happy to mentor and be mentored!" }
      years_experience { rand(3..10) }
    end
    
    trait :complete do
      name { Faker::Name.name }
      bio { Faker::Lorem.paragraph(sentence_count: 5) }
      years_experience { rand(1..15) }
      timezone { "America/New_York" }
      skills { "Ruby, Rails, PostgreSQL, JavaScript, React" }
      availability { "Monday-Friday 6-9pm EST, Saturdays 10am-2pm EST" }
      github_url { "https://github.com/#{Faker::Internet.username}" }
      x_url { "https://x.com/#{Faker::Internet.username}" }
      website_url { "https://#{Faker::Internet.domain_name}" }
    end
    
    trait :without_urls do
      github_url { nil }
      x_url { nil }
      website_url { nil }
    end
  end
end

