class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one :profile, dependent: :destroy
  has_many :mentorship_requests_as_mentee, class_name: "MentorshipRequest", foreign_key: :mentee_id, dependent: :nullify
  has_many :mentorship_requests_as_mentor, class_name: "MentorshipRequest", foreign_key: :mentor_id, dependent: :nullify
  has_many :messages, dependent: :destroy
end
