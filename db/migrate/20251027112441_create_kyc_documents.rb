class CreateKycDocuments < ActiveRecord::Migration[7.2]
  def change
    create_table :kyc_documents do |t|
      t.references :company, null: false, foreign_key: true, index: true
      t.string :document_type, limit: 50, null: false
      t.string :document_url, limit: 500, null: false
      t.string :status, limit: 50, default: 'pending_review'
      t.datetime :uploaded_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.datetime :reviewed_at
      t.string :reviewed_by, limit: 255
      t.date :expiry_date
      t.text :rejection_reason
      t.text :notes
      t.integer :file_size_kb

      t.timestamps
    end

    add_index :kyc_documents, :document_type
    add_index :kyc_documents, :status
  end
end
