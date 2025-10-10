# Ruby Pair (Pay It Forward) - Project Index

## 📋 Project Overview

**Ruby Pair** is a Rails 8 mentorship platform connecting experienced Ruby developers (mentors) with junior developers (mentees). The app facilitates mentor discovery, mentorship requests, and direct messaging.

## 🏗️ Architecture

- **Framework**: Rails 8.0.2+ with Hotwire (Turbo + Stimulus)
- **Frontend**: Tailwind CSS, Importmap (no Node.js)
- **Database**: PostgreSQL
- **Authentication**: Devise
- **Deployment**: Kamal-ready with Docker

## 📁 Directory Structure

```
ruby_buddy/
├── 📄 Core Documentation
│   ├── README.md                 # Basic Rails setup info
│   ├── activeContext.md          # Project objectives and current scope
│   ├── codebaseSummary.md        # Technical structure overview
│   ├── systemPatterns.md         # Architecture patterns and conventions
│   └── PROJECT_INDEX.md          # This comprehensive index
│
├── 🎯 Application Core
│   └── app/
│       ├── controllers/
│       │   ├── application_controller.rb      # Base controller
│       │   ├── home_controller.rb             # Landing page (root route)
│       │   ├── profiles_controller.rb         # Mentor/mentee profiles
│       │   ├── mentorship_requests_controller.rb  # Mentorship requests
│       │   └── messages_controller.rb         # Messaging system
│       │
│       ├── models/
│       │   ├── application_record.rb          # Base model
│       │   ├── user.rb                        # Devise authentication
│       │   ├── profile.rb                     # User profiles (mentor/mentee)
│       │   ├── mentorship_request.rb          # Request matching system
│       │   └── message.rb                     # Threaded messaging
│       │
│       ├── views/
│       │   ├── layouts/
│       │   │   └── application.html.erb       # Main layout with header/flash
│       │   ├── home/
│       │   │   └── index.html.erb             # Hero landing page
│       │   ├── profiles/                      # Profile management views
│       │   ├── mentorship_requests/           # Request management views
│       │   └── messages/                      # Messaging interface
│       │
│       ├── helpers/                           # View helpers for each controller
│       ├── mailers/                           # Email functionality
│       ├── jobs/                              # Background job processing
│       └── assets/
│           └── stylesheets/
│               └── application.tailwind.css   # Tailwind styles
│
├── ⚙️ Configuration
│   └── config/
│       ├── application.rb                     # PayItForward module config
│       ├── routes.rb                          # Route definitions
│       ├── database.yml                       # PostgreSQL config
│       └── environments/                      # Environment-specific settings
│
├── 🗄️ Database
│   └── db/
│       ├── migrate/                           # Migration files
│       └── schema.rb                          # Current database schema
│
├── 🧪 Testing
│   └── test/
│       ├── models/                            # Model tests
│       ├── controllers/                       # Controller tests
│       └── system/                            # Integration tests
│
└── 🚀 Deployment & Tools
    ├── .kamal/                                # Kamal deployment config
    ├── Dockerfile                             # Container configuration
    ├── Gemfile                                # Ruby dependencies
    └── bin/                                   # Executable scripts
```

## 🏛️ Core Models & Relationships

### User (Devise)

- **Purpose**: Authentication and base user management
- **Relationships**: `has_one :profile`, `has_many :mentorship_requests`, `has_many :messages`

### Profile

- **Purpose**: Public mentor/mentee profiles with skills and availability
- **Key Fields**: `name`, `bio`, `years_experience`, `timezone`, `skills`, `mentor`, `mentee`
- **Relationships**: `belongs_to :user`

### MentorshipRequest

- **Purpose**: Connection requests between mentees and mentors
- **Key Fields**: `topic`, `goals`, `preferred_times`, `status` (enum: open/accepted/closed)
- **Relationships**: `belongs_to :mentee (User)`, `belongs_to :mentor (User)`, `has_many :messages`

### Message

- **Purpose**: Threaded messaging within mentorship requests
- **Key Fields**: `body`, `created_at`
- **Relationships**: `belongs_to :mentorship_request`, `belongs_to :user`

## 🛣️ Key Routes

```ruby
root 'home#index'                    # Landing page
devise_for :users                    # Authentication routes
resources :profiles                  # Mentor directory & profile management
resources :mentorship_requests       # Request system
resources :messages                  # Messaging system
```

## 🎨 Frontend Technology

- **Styling**: Tailwind CSS with utility-first approach
- **JavaScript**: Hotwire (Turbo + Stimulus) for SPA-like experience
- **Assets**: Importmap (no Node.js build process)
- **Layout**: Fixed translucent header, hero sections, responsive grids

## 🔐 Authentication & Authorization

- **System**: Devise with email/password
- **Access Control**:
  - Profiles: Public browsing, authenticated CRUD
  - Requests: Authenticated users, scoped to participation
  - Messages: Authenticated, limited to request participants

## 🗃️ Database Schema

```sql
# PostgreSQL databases with pay_it_forward_* prefix
- users (Devise standard fields)
- profiles (user_id, name, bio, skills, mentor/mentee flags)
- mentorship_requests (mentee_id, mentor_id, topic, status)
- messages (mentorship_request_id, user_id, body)
```

## 🚀 Development Commands

```bash
# Setup
bin/rails db:create db:migrate

# Development server
bin/dev                              # Starts Rails + Tailwind watcher

# Testing
bin/rails test                       # Run test suite
bin/rails test:system               # System tests

# Code quality
bundle exec rubocop                  # Style checking
bundle exec brakeman                 # Security analysis
```

## 🎯 Current MVP Features

✅ **Implemented**:

- User authentication (Devise)
- Public mentor directory with search
- Profile management (mentor/mentee flags)
- Mentorship request system
- Threaded messaging
- Responsive Tailwind UI

🚧 **Future Enhancements**:

- Skills taxonomy with tags
- Calendar integration for availability
- Email notifications
- Mentor verification system
- Admin moderation features

## 🔍 Quick Navigation

### Need to find

- **Landing page**: `app/views/home/index.html.erb`
- **User authentication**: `app/models/user.rb` + Devise config
- **Mentor directory**: `app/controllers/profiles_controller.rb`
- **Request system**: `app/controllers/mentorship_requests_controller.rb`
- **Messaging**: `app/controllers/messages_controller.rb`
- **Database schema**: `db/schema.rb`
- **Routes**: `config/routes.rb`
- **Styling**: `app/assets/stylesheets/application.tailwind.css`

### Common tasks locations

- **Add new feature**: Start with `config/routes.rb`, then generate controller/model
- **Modify UI**: Views in `app/views/`, styles in Tailwind classes
- **Database changes**: Create migration with `bin/rails generate migration`
- **Authentication logic**: Check `app/controllers/application_controller.rb`
- **Business logic**: Models in `app/models/`

---

*Last updated: Generated automatically on project indexing*
