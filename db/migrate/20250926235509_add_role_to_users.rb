class AddRoleToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :role, :string
    add_column :users, :onboarding_completed, :boolean, default: false
    add_index :users, :role
  end
end
