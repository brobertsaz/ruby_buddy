class AddIndexesToMessages < ActiveRecord::Migration[8.0]
  def change
    # Index for finding unread messages in a specific mentorship request
    add_index :messages, [:mentorship_request_id, :read_at], name: 'index_messages_on_request_and_read_status'

    # Index for finding messages by status (sent_at/read_at queries)
    add_index :messages, :sent_at
    add_index :messages, :read_at

    # Composite index for efficient unread message counting
    add_index :messages, [:mentorship_request_id, :user_id, :read_at], name: 'index_messages_for_unread_count'
  end
end
