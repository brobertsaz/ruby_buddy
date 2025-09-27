class CreateConversationMetadata < ActiveRecord::Migration[8.0]
  def change
    create_table :conversation_metadata do |t|
      t.references :mentorship_request, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.boolean :typing, default: false, null: false
      t.datetime :typing_updated_at

      t.timestamps
    end

    # Add composite index for efficient lookups
    add_index :conversation_metadata, [:mentorship_request_id, :user_id], unique: true, name: 'index_conversation_metadata_on_request_and_user'
    add_index :conversation_metadata, [:mentorship_request_id, :typing], name: 'index_conversation_metadata_on_request_and_typing'
  end
end
