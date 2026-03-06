class AddLegalRepresentativeDobToCompanies < ActiveRecord::Migration[7.2]
  def change
    add_column :companies, :legal_representative_dob, :date
  end
end
