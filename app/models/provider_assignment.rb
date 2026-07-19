class ProviderAssignment < ApplicationRecord
  belongs_to :provider
  belongs_to :client

  enum :plan, { basic: 0, premium: 1 }

  validates :plan, presence: true
  validates :provider_id, uniqueness: { scope: :client_id }

  scope :recent, -> { order(created_at: :desc) }
end
