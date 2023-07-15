class UserSocial < ApplicationRecord
  belongs_to :user
  belongs_to :social_network

  validates :url, presence: true
end
