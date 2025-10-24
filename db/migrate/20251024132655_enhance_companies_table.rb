class EnhanceCompaniesTable < ActiveRecord::Migration[7.2]
  def change
    add_column :companies, :logo_url, :string
    add_column :companies, :iban, :string, limit: 34
    add_column :companies, :annual_revenue, :decimal, precision: 15, scale: 2
    add_column :companies, :employee_count, :integer
    add_column :companies, :registration_date, :date

    add_index :companies, :iban
  end
end
