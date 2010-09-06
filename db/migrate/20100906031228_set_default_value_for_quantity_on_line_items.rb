class SetDefaultValueForQuantityOnLineItems < ActiveRecord::Migration
  def self.up
    change_column :line_items, :quantity, :integer, :default => 1
  end

  def self.down
    change_column :line_items, :quantity, :integer
  end
end
