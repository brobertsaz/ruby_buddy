class MentorshipRequest < ApplicationRecord
  belongs_to :mentee, class_name: "User"
  belongs_to :mentor, class_name: "User", optional: true

  enum :status, { open: 0, accepted: 1, closed: 2 }

  has_many :messages, dependent: :destroy

  validates :topic, presence: true
end
