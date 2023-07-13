class RenameColumnsInUserSocials < ActiveRecord::Migration[7.0]
  def change
    rename_column :user_socials, :users_id, :user_id
    rename_column :user_socials, :social_networks_id, :social_network_id
  end
end
