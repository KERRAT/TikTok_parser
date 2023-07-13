class User < ApplicationRecord
  has_many :user_socials
  has_many :social_networks, through: :user_socials
end
