class BackfillMessageStatusValues < ActiveRecord::Migration[8.0]
  def up
    # Backfill sent_at for existing messages that don't have it
    # Set sent_at to the created_at timestamp for existing messages
    execute <<-SQL
      UPDATE messages
      SET sent_at = created_at
      WHERE sent_at IS NULL;
    SQL

    # For demo purposes, mark some older messages as read
    # This simulates a real-world scenario where some messages would already be read
    execute <<-SQL
      UPDATE messages
      SET read_at = created_at + INTERVAL '1 hour'
      WHERE created_at < NOW() - INTERVAL '1 day'
      AND read_at IS NULL;
    SQL

    say "Backfilled sent_at for #{Message.where(sent_at: nil).count} messages"
    say "Marked older messages as read for demo purposes"
  end

  def down
    # This is a data migration, so we don't reverse the backfill
    # The data represents the historical state
    say "Data migration - no rollback performed"
  end
end
