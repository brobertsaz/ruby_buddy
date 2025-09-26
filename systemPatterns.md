Architecture & Patterns

Framework
- Rails 8 standard MVC with Hotwire (Turbo + Stimulus) and Importmap.
- Tailwind (tailwindcss-rails) for styling; utility-first + small component partials.
- PostgreSQL for persistence.

Authentication & Authorization
- Devise for auth (email/password).
- Controllers use `before_action :authenticate_user!` for mutating actions.
- Access rules (MVP):
  - Profiles: index/show public; new/create/edit/update/destroy require login; each user owns a single profile.
  - MentorshipRequests: new/create/update/destroy require login; index shows relevant requests for current_user; public sees open requests.
  - Messages: require login; user may post only within requests they’re party to (mentee/mentor).

Domain Model
- User has_one Profile, has_many MentorshipRequests as mentee and mentor, has_many Messages.
- Profile belongs_to User; flags: mentor/mentee (booleans, default false).
- MentorshipRequest belongs_to mentee (User) and optional mentor (User); enum status: open (0), accepted (1), closed (2).
- Message belongs_to MentorshipRequest and User.

Controllers
- Use params.expect (Rails 8) for strong params.
- Build associations through current_user where applicable (no permitting *_id from forms for ownership fields).

Views & UX
- Tailwind containers with 
  - Fixed translucent header
  - Strong landing hero
  - Mentor cards grid and simple search (ILIKE over name/skills/bio)
- Keep scaffolds, progressively enhance.

Testing (direction)
- System tests for sign up, profile creation, request creation, and messaging.
- Model tests: validations and enum transitions.

Conventions
- Use PORO services for complex operations if/when needed (e.g., matching algorithm).
- Keep controllers thin; push query logic to model scopes in future iterations.
- No fake seed data by default.

Deployment
- Kamal files are scaffolded by Rails 8; configure later as needed.

