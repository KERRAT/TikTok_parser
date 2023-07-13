class UserSocials < ApplicationRecord
  belongs_to :user
  belongs_to :social_network
end
