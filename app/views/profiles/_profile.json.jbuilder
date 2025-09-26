json.extract! profile, :id, :user_id, :name, :bio, :years_experience, :timezone, :skills, :availability, :github_url, :x_url, :website_url, :mentor, :mentee, :created_at, :updated_at
json.url profile_url(profile, format: :json)
