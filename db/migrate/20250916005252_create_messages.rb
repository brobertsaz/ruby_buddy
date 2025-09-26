class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :mentorship_request, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :body

      t.timestamps
    end
  end
end
