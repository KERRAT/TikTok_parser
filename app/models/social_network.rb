class SocialNetwork < ApplicationRecord
  has_many :user_socials
  has_many :users, through: :user_socials

  validates :name, :base_link, presence: true
end
