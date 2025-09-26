class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :bio
      t.integer :years_experience
      t.string :timezone
      t.string :skills
      t.text :availability
      t.string :github_url
      t.string :x_url
      t.string :website_url
      t.boolean :mentor, default: false, null: false
      t.boolean :mentee, default: false, null: false

      t.timestamps
    end
  end
end
