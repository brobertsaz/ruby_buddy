# Database Schema

This is the database schema implementation for the spec detailed in @.agent-os/specs/2025-09-26-enhanced-chat-interface/spec.md

> Created: 2025-09-26
> Version: 1.0.0

## Schema Changes

The enhanced chat interface requires message status tracking to provide real-time delivery confirmation and read receipts. The existing `messages` table needs to be extended with timestamp fields to track message lifecycle events.

### Messages Table Modifications

**Current Structure:**
- `mentorship_request_id` (foreign key)
- `user_id` (foreign key)
- `body` (text)
- `created_at` (timestamp)
- `updated_at` (timestamp)

**Required Additions:**
- `sent_at` (timestamp, nullable) - When message was successfully delivered
- `read_at` (timestamp, nullable) - When message was read by recipient

### Rationale for Changes

1. **sent_at timestamp**: Tracks when a message transitions from "pending" to "delivered" state, enabling delivery confirmations
2. **read_at timestamp**: Tracks when recipient views the message, enabling read receipts
3. **Nullable fields**: Messages start as created but not yet sent, allowing for draft/queued states
4. **Performance indexes**: Support efficient queries for unread message counts and status filtering

## Migrations

### Rails Migration: Add Message Status Fields

```ruby
class AddStatusFieldsToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :sent_at, :timestamp, null: true
    add_column :messages, :read_at, :timestamp, null: true

    # Index for efficient unread message queries
    add_index :messages, [:mentorship_request_id, :read_at],
              name: 'index_messages_on_request_and_read_status'

    # Index for message status queries by user
    add_index :messages, [:user_id, :sent_at],
              name: 'index_messages_on_user_and_sent_status'

    # Composite index for conversation view with status
    add_index :messages, [:mentorship_request_id, :created_at, :read_at],
              name: 'index_messages_on_conversation_with_status'
  end
end
```

### Migration: Backfill Existing Messages

```ruby
class BackfillMessageStatusFields < ActiveRecord::Migration[8.0]
  def up
    # Set sent_at to created_at for existing messages (assume they were sent)
    execute <<-SQL
      UPDATE messages
      SET sent_at = created_at
      WHERE sent_at IS NULL
    SQL

    # Leave read_at as NULL for existing messages to maintain accurate read status
  end

  def down
    # Reset status fields
    execute <<-SQL
      UPDATE messages
      SET sent_at = NULL, read_at = NULL
    SQL
  end
end
```

### Database Constraints

```ruby
class AddMessageStatusConstraints < ActiveRecord::Migration[8.0]
  def change
    # Ensure read_at cannot be before sent_at
    add_check_constraint :messages,
                        "read_at IS NULL OR sent_at IS NULL OR read_at >= sent_at",
                        name: "messages_read_after_sent_check"

    # Ensure sent_at cannot be before created_at
    add_check_constraint :messages,
                        "sent_at IS NULL OR sent_at >= created_at",
                        name: "messages_sent_after_created_check"
  end
end
```

## Performance Considerations

### Indexes Rationale

1. **index_messages_on_request_and_read_status**: Optimizes queries for unread message counts per conversation
2. **index_messages_on_user_and_sent_status**: Supports user dashboard queries for message delivery status
3. **index_messages_on_conversation_with_status**: Enables efficient conversation loading with read status

### Query Patterns Supported

```ruby
# Unread messages count for a conversation
Message.where(mentorship_request_id: id, read_at: nil).count

# Messages sent but not delivered
Message.where(user_id: current_user.id, sent_at: nil).count

# Conversation messages with status for UI
Message.where(mentorship_request_id: id)
       .order(:created_at)
       .select(:id, :body, :user_id, :created_at, :sent_at, :read_at)
```

## Model Updates Required

The `Message` model will need scope additions:

```ruby
class Message < ApplicationRecord
  scope :unread, -> { where(read_at: nil) }
  scope :sent, -> { where.not(sent_at: nil) }
  scope :pending, -> { where(sent_at: nil) }
  scope :delivered, -> { where.not(sent_at: nil).where(read_at: nil) }

  def status
    return :read if read_at.present?
    return :delivered if sent_at.present?
    :pending
  end
end
```