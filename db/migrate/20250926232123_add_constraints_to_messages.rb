class AddConstraintsToMessages < ActiveRecord::Migration[8.0]
  def change
    # Add check constraint to ensure read_at is after sent_at
    execute <<-SQL
      ALTER TABLE messages
      ADD CONSTRAINT check_read_at_after_sent_at
      CHECK (read_at IS NULL OR sent_at IS NULL OR read_at >= sent_at);
    SQL

    # Add check constraint to ensure sent_at is after created_at
    execute <<-SQL
      ALTER TABLE messages
      ADD CONSTRAINT check_sent_at_after_created_at
      CHECK (sent_at IS NULL OR sent_at >= created_at);
    SQL

    # Add check constraint to ensure read_at is after created_at
    execute <<-SQL
      ALTER TABLE messages
      ADD CONSTRAINT check_read_at_after_created_at
      CHECK (read_at IS NULL OR read_at >= created_at);
    SQL
  end

  def down
    execute "ALTER TABLE messages DROP CONSTRAINT IF EXISTS check_read_at_after_sent_at;"
    execute "ALTER TABLE messages DROP CONSTRAINT IF EXISTS check_sent_at_after_created_at;"
    execute "ALTER TABLE messages DROP CONSTRAINT IF EXISTS check_read_at_after_created_at;"
  end
end
