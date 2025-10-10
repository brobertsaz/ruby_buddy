class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @my_requests = current_user.mentorship_requests_as_mentee.order(created_at: :desc).limit(5)
    @mentor_requests = current_user.mentorship_requests_as_mentor.order(created_at: :desc).limit(5)

    # Get unread message counts
    @unread_messages_count = Message.joins(:mentorship_request)
                                    .where("mentorship_requests.mentee_id = ? OR mentorship_requests.mentor_id = ?",
                                           current_user.id, current_user.id)
                                    .where.not(user_id: current_user.id)
                                    .where(read_at: nil)
                                    .count

    # Get active mentorships (accepted requests)
    @active_mentorships = MentorshipRequest.where("(mentee_id = ? OR mentor_id = ?) AND status = ?",
                                                   current_user.id, current_user.id, 1)
                                           .order(updated_at: :desc)

    # Get pending requests (for mentors)
    if current_user.mentor?
      @pending_requests = MentorshipRequest.where(mentor_id: current_user.id, status: 0)
                                          .order(created_at: :desc)
                                          .limit(5)
    end
  end
end

