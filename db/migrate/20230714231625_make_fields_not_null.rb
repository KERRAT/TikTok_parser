class MakeFieldsNotNull < ActiveRecord::Migration[7.0]
  def change
    change_column_null :social_networks, :name, false
    change_column_null :social_networks, :base_link, false
    change_column_null :user_socials, :url, false
    change_column_null :users, :tiktok_link, false
  end
end
