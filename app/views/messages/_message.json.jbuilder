json.extract! message, :id, :mentorship_request_id, :user_id, :body, :created_at, :updated_at
json.url message_url(message, format: :json)
