class DropBookLibraryTables < ActiveRecord::Migration[7.2]
  def up
    drop_table :loans if table_exists?(:loans)
    drop_table :books if table_exists?(:books)
    drop_table :authors if table_exists?(:authors)
    drop_table :categories if table_exists?(:categories)
    drop_table :users if table_exists?(:users)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
