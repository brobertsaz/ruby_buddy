# Ruby Buddy - Seed Data
# Creates sample users, mentors, mentorship requests, and chat conversations
# to showcase the beautiful chat interface and onboarding flow

puts "🌱 Seeding Ruby Buddy with amazing data..."

# Clear existing data in development
if Rails.env.development?
  puts "🧹 Cleaning up existing data..."
  Message.destroy_all
  ConversationMetadata.destroy_all
  MentorshipRequest.destroy_all
  Profile.destroy_all
  User.destroy_all
end

# Create Users with different roles
puts "👥 Creating diverse Ruby community members..."

# Experienced Mentors
mentors_data = [
  {
    email: "sarah.mentor@ruby.dev",
    name: "Sarah Chen",
    role: "mentor",
    bio: "Senior Rails developer with 8+ years building scalable web applications. Love helping newcomers navigate their Ruby journey! 🚀",
    skills: ["Ruby on Rails", "PostgreSQL", "API Design", "Testing", "Performance"],
    github: "sarah-codes",
    experience: "8 years"
  },
  {
    email: "alex.senior@rubygems.org",
    name: "Alex Rodriguez",
    role: "mentor",
    bio: "Full-stack developer and open source contributor. Been writing Ruby since 2015 and love sharing knowledge through mentorship! 💎",
    skills: ["Ruby", "JavaScript", "Docker", "AWS", "GraphQL"],
    github: "alexr-dev",
    experience: "9 years"
  },
  {
    email: "jamie.lead@startup.io",
    name: "Jamie Thompson",
    role: "mentor",
    bio: "Tech lead who's passionate about clean code and helping junior developers grow. Let's build something amazing together! ✨",
    skills: ["Ruby on Rails", "System Design", "Team Leadership", "Code Review", "Mentoring"],
    github: "jamie-builds",
    experience: "12 years"
  },
  {
    email: "morgan.expert@consultancy.com",
    name: "Morgan Davis",
    role: "mentor",
    bio: "Ruby consultant specializing in legacy system modernization. Here to help you avoid the pitfalls I've learned from! 🔧",
    skills: ["Legacy Rails", "Database Optimization", "Refactoring", "Architecture", "Debugging"],
    github: "morgan-ruby",
    experience: "15 years"
  }
]

# Eager Mentees
mentees_data = [
  {
    email: "lisa.newbie@student.edu",
    name: "Lisa Wang",
    role: "mentee",
    learning_goals: "Just started learning Ruby! Looking for guidance on Rails fundamentals and building my first web app. 📚"
  },
  {
    email: "carlos.junior@bootcamp.edu",
    name: "Carlos Martinez",
    role: "mentee",
    learning_goals: "Recent bootcamp grad seeking help with advanced Rails patterns, testing, and preparing for job interviews. 🎯"
  },
  {
    email: "emma.career@switcher.com",
    name: "Emma Johnson",
    role: "mentee",
    learning_goals: "Career switcher from marketing to development. Need help understanding Ruby ecosystem and best practices! 🚀"
  },
  {
    email: "david.intern@company.com",
    name: "David Kim",
    role: "mentee",
    learning_goals: "CS student doing Ruby internship. Want to learn industry standards and how to write production-ready code. 💻"
  }
]

# Community Members (Both)
community_data = [
  {
    email: "taylor.community@ruby.town",
    name: "Taylor Wilson",
    role: "both",
    bio: "Mid-level developer who loves both learning and teaching. Happy to mentor beginners while seeking advanced guidance! 🤝",
    skills: ["Ruby on Rails", "React", "Testing"],
    github: "taylor-learns",
    experience: "4 years",
    learning_goals: "Want to deepen my understanding of system design and performance optimization."
  },
  {
    email: "riley.growing@dev.world",
    name: "Riley Anderson",
    role: "both",
    bio: "Growing developer passionate about the Ruby community. Love helping others while continuing to learn myself! 🌱",
    skills: ["Ruby", "SQL", "Git"],
    github: "riley-codes",
    experience: "2 years",
    learning_goals: "Looking to learn advanced Ruby patterns and contribute to open source projects."
  }
]

created_users = {}

# Create mentor users
mentors_data.each do |mentor_data|
  user = User.create!(
    email: mentor_data[:email],
    password: "password123",
    password_confirmation: "password123",
    role: mentor_data[:role],
    onboarding_completed: true
  )

  # Create mentor profile
  Profile.create!(
    user: user,
    name: mentor_data[:name],
    bio: mentor_data[:bio],
    skills: mentor_data[:skills].join(", "),
    github_url: "https://github.com/#{mentor_data[:github]}",
    years_experience: mentor_data[:experience].split(' ').first.to_i,
    mentor: true
  )

  created_users[mentor_data[:email]] = user
  puts "✅ Created mentor: #{mentor_data[:name]}"
end

# Create mentee users
mentees_data.each do |mentee_data|
  user = User.create!(
    email: mentee_data[:email],
    password: "password123",
    password_confirmation: "password123",
    role: mentee_data[:role],
    onboarding_completed: true
  )

  created_users[mentee_data[:email]] = user
  puts "✅ Created mentee: #{mentee_data[:name]}"
end

# Create community users (both mentor/mentee)
community_data.each do |community_member|
  user = User.create!(
    email: community_member[:email],
    password: "password123",
    password_confirmation: "password123",
    role: community_member[:role],
    onboarding_completed: true
  )

  # Create profile since they can mentor
  Profile.create!(
    user: user,
    name: community_member[:name],
    bio: community_member[:bio],
    skills: community_member[:skills].join(", "),
    github_url: "https://github.com/#{community_member[:github]}",
    years_experience: community_member[:experience].split(' ').first.to_i,
    mentor: true
  )

  created_users[community_member[:email]] = user
  puts "✅ Created community member: #{community_member[:name]}"
end

puts "\n💬 Creating mentorship requests and conversations..."

# Create mentorship requests with conversations
requests_data = [
  {
    mentee: created_users["lisa.newbie@student.edu"],
    mentor: created_users["sarah.mentor@ruby.dev"],
    topic: "Ruby on Rails Fundamentals",
    description: "Hi! I'm completely new to Ruby and Rails. I've been working through tutorials but I'm getting stuck on basic concepts like routing, controllers, and the Rails way of doing things. Would love some guidance on building my first real app! 🙏",
    status: :accepted,
    messages: [
      { user: "lisa.newbie@student.edu", body: "Hi Sarah! Thank you so much for accepting my request. I'm super excited to learn from you! 😊", sent_hours_ago: 24 },
      { user: "sarah.mentor@ruby.dev", body: "Hi Lisa! Welcome to the Ruby community! I'm excited to help you on your journey. What specific part of Rails are you finding most challenging right now?", sent_hours_ago: 23 },
      { user: "lisa.newbie@student.edu", body: "I think I'm struggling most with understanding how all the pieces fit together - like when I make a change in a controller, how does it affect the view? And I keep getting confused about routes.", sent_hours_ago: 23 },
      { user: "sarah.mentor@ruby.dev", body: "That's totally normal! The MVC pattern can be confusing at first. Let me share a simple way to think about it: Routes → Controllers → Models → Views. Each step hands off to the next. Want to build a small example together?", sent_hours_ago: 22 },
      { user: "lisa.newbie@student.edu", body: "Yes please! That would be amazing. Should I create a new Rails app or work with something existing?", sent_hours_ago: 22 },
      { user: "sarah.mentor@ruby.dev", body: "Let's start fresh! Run `rails new blog_app` and we'll build a simple blog together. This will help you see exactly how routes, controllers, and views work together. 🚀", sent_hours_ago: 21 },
      { user: "lisa.newbie@student.edu", body: "Perfect! I just created the app. What's our first step?", sent_hours_ago: 2 }
    ]
  },
  {
    mentee: created_users["carlos.junior@bootcamp.edu"],
    mentor: created_users["alex.senior@rubygems.org"],
    topic: "Testing Best Practices & Job Interview Prep",
    description: "I just finished a coding bootcamp and have been building projects, but I'm struggling with writing good tests and preparing for technical interviews. Looking for help with RSpec, testing strategies, and common interview questions for Ruby positions.",
    status: :accepted,
    messages: [
      { user: "carlos.junior@bootcamp.edu", body: "Hi Alex! I saw your profile and you seem like exactly the mentor I need. I'm preparing for Ruby developer interviews and really need help with testing.", sent_hours_ago: 48 },
      { user: "alex.senior@rubygems.org", body: "Hey Carlos! Congrats on finishing bootcamp - that's a huge accomplishment! 🎉 I'd love to help you with testing and interview prep. What's your current experience with RSpec?", sent_hours_ago: 47 },
      { user: "carlos.junior@bootcamp.edu", body: "Thanks! I know the basics of RSpec but I struggle with knowing what to test and how to structure my tests. My bootcamp didn't go deep into testing patterns.", sent_hours_ago: 46 },
      { user: "alex.senior@rubygems.org", body: "Great starting point! Testing is an art as much as a science. Let's start with the testing pyramid: Unit tests (models) → Integration tests (controllers) → System tests (full stack). Want to review one of your projects together?", sent_hours_ago: 45 },
      { user: "carlos.junior@bootcamp.edu", body: "That would be incredible! I have a Rails API project for a task manager. Should I share the GitHub repo?", sent_hours_ago: 44 },
      { user: "alex.senior@rubygems.org", body: "Perfect! Send me the repo link. We'll add comprehensive tests and I'll show you what employers typically look for in junior developer code. 💪", sent_hours_ago: 43 },
      { user: "carlos.junior@bootcamp.edu", body: "Here it is: github.com/carlos-dev/task-manager-api - I know the tests are pretty basic right now 😅", sent_hours_ago: 1 }
    ]
  },
  {
    mentee: created_users["emma.career@switcher.com"],
    mentor: created_users["jamie.lead@startup.io"],
    topic: "Career Switch to Ruby Development",
    description: "I'm switching careers from marketing to software development and chose Ruby as my first language. I have basic programming knowledge but need guidance on the Ruby ecosystem, best practices, and how to build a portfolio that will get me hired.",
    status: :accepted,
    messages: [
      { user: "emma.career@switcher.com", body: "Hi Jamie! I'm making a big career change and Ruby is my chosen path. Your background as a tech lead is exactly what I need guidance from!", sent_hours_ago: 72 },
      { user: "jamie.lead@startup.io", body: "Hi Emma! Career switching takes courage - I admire that! 🌟 I switched from finance to tech myself years ago. What drew you to Ruby specifically?", sent_hours_ago: 71 },
      { user: "emma.career@switcher.com", body: "I love how readable and elegant Ruby code is compared to other languages I tried. Plus the community seems so welcoming! But I'm overwhelmed by all the gems, frameworks, and tools.", sent_hours_ago: 70 },
      { user: "jamie.lead@startup.io", body: "You picked a great language! The Ruby community really is special. Let's build you a learning roadmap: Ruby basics → Rails → Git/GitHub → Testing → Deploy a project. Sound good?", sent_hours_ago: 69 },
      { user: "emma.career@switcher.com", body: "That sounds perfect and manageable! Should I focus on building several small projects or one larger one for my portfolio?", sent_hours_ago: 68 },
      { user: "jamie.lead@startup.io", body: "Both! Start with 2-3 small projects to learn fundamentals, then build one polished project that showcases everything you've learned. Quality over quantity for your portfolio! ✨", sent_hours_ago: 67 },
      { user: "emma.career@switcher.com", body: "I'm starting to feel more confident about this path. Thank you for the encouragement and clear direction! 🙏", sent_hours_ago: 4 }
    ]
  },
  {
    mentee: created_users["david.intern@company.com"],
    mentor: created_users["morgan.expert@consultancy.com"],
    topic: "Production Ruby Code & Industry Standards",
    description: "I'm a CS student doing an internship where I'm working on a legacy Rails application. I want to learn how to write production-quality Ruby code and understand industry best practices for maintaining large codebases.",
    status: :accepted,
    messages: [
      { user: "david.intern@company.com", body: "Hi Morgan! I'm working on my first production Rails app as an intern and feeling overwhelmed. The codebase is huge and I'm not sure I'm following the right patterns.", sent_hours_ago: 36 },
      { user: "morgan.expert@consultancy.com", body: "Hey David! Legacy Rails apps can definitely be intimidating at first. Don't worry - every senior dev has been there! 😊 What's the biggest challenge you're facing right now?", sent_hours_ago: 35 },
      { user: "david.intern@company.com", body: "I think it's understanding how to add new features without breaking existing functionality. The test suite takes forever to run and some tests seem fragile.", sent_hours_ago: 34 },
      { user: "morgan.expert@consultancy.com", body: "Ah, the classic legacy codebase challenges! Slow tests and brittle specs are common issues. Let's talk about safe refactoring techniques and how to add features incrementally. Have you heard of the Strangler Fig pattern?", sent_hours_ago: 33 },
      { user: "david.intern@company.com", body: "No, I haven't! Is that a way to gradually improve legacy code?", sent_hours_ago: 32 },
      { user: "morgan.expert@consultancy.com", body: "Exactly! It's about gradually replacing old code with new code, piece by piece, like how a strangler fig grows around a tree. Perfect for legacy apps. Want me to show you how to apply it to a real example?", sent_hours_ago: 31 },
      { user: "david.intern@company.com", body: "That would be amazing! I have a specific feature I'm working on that might be perfect for this approach.", sent_hours_ago: 30 },
      { user: "morgan.expert@consultancy.com", body: "Great! Share the details and we'll walk through it together. This is exactly the kind of real-world experience that will make you a stronger developer! 🚀", sent_hours_ago: 6 }
    ]
  },
  {
    mentee: created_users["riley.growing@dev.world"],
    mentor: created_users["taylor.community@ruby.town"],
    topic: "Advanced Ruby Patterns & Open Source",
    description: "I've been coding Ruby for 2 years and want to level up my skills. Looking for guidance on advanced patterns, contributing to open source, and becoming a better developer overall. Also hoping to start mentoring others soon!",
    status: :accepted,
    messages: [
      { user: "riley.growing@dev.world", body: "Hey Taylor! I love that we're both on the learning and teaching journey. I'd love to learn from your experience while we grow together! 🌱", sent_hours_ago: 12 },
      { user: "taylor.community@ruby.town", body: "Hi Riley! I love this approach - we can definitely learn from each other! What specific advanced patterns are you interested in exploring?", sent_hours_ago: 11 },
      { user: "riley.growing@dev.world", body: "I keep hearing about things like decorators, service objects, and command patterns but I'm not sure when to use them. My code works but doesn't feel 'professional' yet.", sent_hours_ago: 10 },
      { user: "taylor.community@ruby.town", body: "Those are great patterns to learn! They're all about organizing code as it grows. I struggled with the same thing. Want to refactor one of your projects together using these patterns?", sent_hours_ago: 9 },
      { user: "riley.growing@dev.world", body: "Yes! That sounds perfect. I have a small e-commerce app that's getting messy - would be great to clean it up with proper patterns.", sent_hours_ago: 8 },
      { user: "taylor.community@ruby.town", body: "E-commerce apps are perfect for learning these patterns! Lots of business logic to organize. Let's start with extracting some service objects. Can you show me your current order processing code?", sent_hours_ago: 7 },
      { user: "riley.growing@dev.world", body: "Here's my current OrdersController - it's doing way too much I think: [code snippet would go here]", sent_hours_ago: 5 }
    ]
  }
]

# Create some open requests too
open_requests_data = [
  {
    mentee: created_users["emma.career@switcher.com"],
    topic: "Ruby Gem Development",
    description: "I want to learn how to create and publish my first Ruby gem. Looking for someone who has experience with gem development, testing gems, and the publishing process.",
    status: :open
  },
  {
    mentee: created_users["carlos.junior@bootcamp.edu"],
    topic: "GraphQL with Ruby",
    description: "My company is considering GraphQL for our API. I have REST experience but need help understanding GraphQL concepts and how to implement it in Ruby/Rails.",
    status: :open
  },
  {
    mentee: created_users["david.intern@company.com"],
    topic: "Ruby Performance Optimization",
    description: "Working on a high-traffic Rails app that's having performance issues. Need guidance on profiling, optimization techniques, and scaling Ruby applications.",
    status: :open
  }
]

# Create the mentorship requests with messages
requests_data.each do |request_data|
  mentorship_request = MentorshipRequest.create!(
    mentee: request_data[:mentee],
    mentor: request_data[:mentor],
    topic: request_data[:topic],
    goals: request_data[:description],
    status: request_data[:status]
  )

  # Create messages for this conversation
  request_data[:messages].each do |message_data|
    user = created_users[message_data[:user]]
    sent_time = message_data[:sent_hours_ago].hours.ago
    read_time = sent_time + rand(30..120).minutes

    Message.create!(
      mentorship_request: mentorship_request,
      user: user,
      body: message_data[:body],
      created_at: sent_time,
      sent_at: sent_time,
      read_at: read_time
    )
  end

  puts "✅ Created conversation: #{request_data[:topic]}"
end

# Create open requests
open_requests_data.each do |request_data|
  MentorshipRequest.create!(
    mentee: request_data[:mentee],
    topic: request_data[:topic],
    goals: request_data[:description],
    status: request_data[:status]
  )

  puts "✅ Created open request: #{request_data[:topic]}"
end

puts "\n🎉 Seeding complete! Here's what was created:"
puts "👥 Users: #{User.count}"
puts "👨‍💻 Mentor Profiles: #{Profile.where(mentor: true).count}"
puts "💬 Mentorship Requests: #{MentorshipRequest.count}"
puts "📝 Messages: #{Message.count}"

puts "\n🚀 Ready to test the amazing chat interface!"
puts "💡 Try logging in as:"
puts "   📧 sarah.mentor@ruby.dev (password: password123) - Experienced mentor"
puts "   📧 lisa.newbie@student.edu (password: password123) - Eager mentee"
puts "   📧 taylor.community@ruby.town (password: password123) - Community member"

puts "\n✨ Visit http://localhost:4000 and see the beautiful onboarding + chat in action!"