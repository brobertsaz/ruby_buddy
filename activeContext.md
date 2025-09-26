Project: Pay It Forward (Rails mentorship platform)

Objective
- Build a fun, beautiful Ruby on Rails app for mentors (experienced Rubyists) and mentees (junior devs) to connect.
- No fake data; focus on real user-generated content.

Current Scope (MVP)
- Public landing page with strong Rails flair and CTAs
- Mentor directory (Profiles), filterable by text query (name/skills/bio)
- Auth via Devise (email/password)
- Profiles: name, bio, years_experience, timezone, skills, links, availability; mentor/mentee flags
- Mentorship Requests: topic, goals, preferred_times, status enum (open/accepted/closed)
- Messaging: threaded messages on each request (user + body)
- Dash-like flows via existing scaffold views

Tech Choices
- Rails 8 + Hotwire (Turbo/Stimulus) + Importmap
- Tailwind via tailwindcss-rails (no Node required)
- PostgreSQL (dev/test/prod database names prefixed with pay_it_forward_*)
- Devise for authentication

Naming
- Rails module: PayItForward
- App title: "Pay It Forward"

Key Routes
- root: HomeController#index
- resources: profiles, mentorship_requests, messages
- devise_for :users

Open Questions / Future Enhancements
- Better mentor skills taxonomy (tags table) and structured filters
- Availability/booking UX (calendar / time slots)
- Notifications (email, Turbo Streams)
- Mentor verification / endorsements
- Admin moderation (soft deletes)

How to run (dev)
- Ensure PostgreSQL is running
- bin/rails db:create db:migrate
- bin/dev (foreman) to run Rails + Tailwind

