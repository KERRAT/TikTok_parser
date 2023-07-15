class AddColumnToUsersTable < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :tiktok_link, :string
  end
end
