class AddColumnToSocialNetworks < ActiveRecord::Migration[7.0]
  def change
    add_column :social_networks, :base_link, :string
  end
end
