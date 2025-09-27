class AddStatusToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :sent_at, :datetime
    add_column :messages, :read_at, :datetime
  end
end
