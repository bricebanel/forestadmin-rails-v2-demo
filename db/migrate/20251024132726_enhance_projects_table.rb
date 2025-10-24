class EnhanceProjectsTable < ActiveRecord::Migration[7.2]
  def change
    add_column :projects, :progress_percentage, :integer, default: 0
    add_column :projects, :contracting_authority_type, :string, limit: 50

    add_index :projects, :contracting_authority_type
  end
end
