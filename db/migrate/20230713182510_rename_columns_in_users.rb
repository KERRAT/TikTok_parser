class RenameColumnsInUsers < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :channel_name, :title
    rename_column :users, :subscribers, :followers
    rename_column :users, :description, :bio
  end
end
