class AddNullConstraintsToUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_null :users, :title, false
    change_column_null :users, :followers, false
    change_column_null :users, :views_on_video, false
    change_column_null :users, :bio, false
    change_column_null :users, :subtitle, false
  end
end
