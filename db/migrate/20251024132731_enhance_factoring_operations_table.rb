class EnhanceFactoringOperationsTable < ActiveRecord::Migration[7.2]
  def change
    add_column :factoring_operations, :documents_received, :boolean, default: false
    add_column :factoring_operations, :risk_score, :integer

    add_index :factoring_operations, :documents_received
  end
end
