Pay It Forward  Rails 8 app

Key Gems
- rails ~> 8.0.2.1
- pg, puma, importmap-rails, turbo-rails, stimulus-rails
- tailwindcss-rails
- devise
- solid_cache, solid_queue, solid_cable
- kamal, thruster, bootsnap

Structure
- app/
  - models/
    - user.rb (Devise)
    - profile.rb (belongs_to :user)
    - mentorship_request.rb (belongs_to :mentee/:mentor Users; enum status; has_many :messages)
    - message.rb (belongs_to :mentorship_request, :user)
  - controllers/
    - home_controller.rb (index)
    - profiles_controller.rb (public index/show; auth for CRUD; text search)
    - mentorship_requests_controller.rb (scoped index; build via current_user)
    - messages_controller.rb (scoped index; create via current_user)
  - views/
    - layouts/application.html.erb (header, flash, containers)
    - home/index.html.erb (hero + CTAs)
    - profiles/* (scaffold + styled index grid)
    - mentorship_requests/* (scaffold; cleaned form)
    - messages/* (scaffold; cleaned form)
  - javascript/ (importmap + turbo + stimulus)
  - assets/tailwind/application.css
- config/
  - application.rb (module PayItForward)
  - routes.rb (root to home#index; resources: profiles, mentorship_requests, messages; devise_for :users)
  - database.yml (pay_it_forward_* DB names)

DB
- users (Devise)
- profiles (user_ref; mentor/mentee booleans default false)
- mentorship_requests (mentee_id, mentor_id [nullable], status default 0)
- messages (mentorship_request_id, user_id)

Run
- bin/rails db:create db:migrate
- bin/dev (foreman) to start app + tailwind build

