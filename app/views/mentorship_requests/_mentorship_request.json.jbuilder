json.extract! mentorship_request, :id, :mentee_id, :mentor_id, :topic, :goals, :preferred_times, :status, :created_at, :updated_at
json.url mentorship_request_url(mentorship_request, format: :json)
