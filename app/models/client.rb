class Client < ApplicationRecord
  validates :name, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    'valid_email_2/email': true
end
