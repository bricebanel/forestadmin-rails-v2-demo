class EnhanceInvoicesTable < ActiveRecord::Migration[7.2]
  def change
    add_column :invoices, :chorus_pro_status, :string, limit: 50
    add_column :invoices, :chorus_pro_id, :string, limit: 100
    add_column :invoices, :document_url, :string

    add_index :invoices, :chorus_pro_status
    add_index :invoices, :chorus_pro_id, unique: true
  end
end
