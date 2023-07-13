class CreateUserSocials < ActiveRecord::Migration[7.0]
  def change
    create_table :user_socials do |t|
      t.references :users, foreign_key: true
      t.references :social_networks, foreign_key: true
      t.string :url

      t.timestamps
    end
  end
end
