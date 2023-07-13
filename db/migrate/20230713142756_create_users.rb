class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :channel_name
      t.integer :subscribers
      t.integer :views_on_video
      t.string :description
      t.string :email, null: true

      t.timestamps
    end
  end
end
