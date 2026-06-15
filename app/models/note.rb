class Note < ApplicationRecord
  belongs_to :client

  validates :content, presence: true

  scope :sorted_by_date, -> { order(created_at: :desc) }
end
