class User < ApplicationRecord
  has_many :user_socials
  has_many :social_networks, through: :user_socials

  validates :title, :followers, :views_on_video, :bio, :subtitle, presence: true
end
