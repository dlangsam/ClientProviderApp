class Client < ApplicationRecord
  has_many :provider_assignments, dependent: :destroy
  has_many :providers, through: :provider_assignments
  has_many :notes, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    'valid_email_2/email': true
end
