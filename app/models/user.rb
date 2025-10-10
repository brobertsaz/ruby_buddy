class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy
  has_many :mentorship_requests_as_mentee, class_name: "MentorshipRequest", foreign_key: :mentee_id, dependent: :destroy
  has_many :mentorship_requests_as_mentor, class_name: "MentorshipRequest", foreign_key: :mentor_id, dependent: :nullify
  has_many :messages, dependent: :destroy

  # User roles
  ROLES = %w[mentee mentor both].freeze
  validates :role, inclusion: { in: ROLES }, allow_blank: true

  # Role helper methods
  def mentee?
    role == 'mentee' || role == 'both'
  end

  def mentor?
    role == 'mentor' || role == 'both'
  end

  def needs_onboarding?
    role.blank? || !onboarding_completed?
  end

  def display_role
    case role
    when 'mentee' then 'Looking for a Mentor'
    when 'mentor' then 'Available Mentor'
    when 'both' then 'Mentor & Mentee'
    else 'Not Set'
    end
  end

  def display_name
    profile&.name || email&.split('@')&.first || 'User'
  end
end
