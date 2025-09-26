class CreateMentorshipRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :mentorship_requests do |t|
      t.references :mentee, null: false, foreign_key: { to_table: :users }
      t.references :mentor, null: true, foreign_key: { to_table: :users }
      t.string :topic
      t.text :goals
      t.string :preferred_times
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
