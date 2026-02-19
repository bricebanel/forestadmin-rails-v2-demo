class RenameKycDocumentTypeValues < ActiveRecord::Migration[7.2]
  VALUE_MAPPING = {
    'kbis'                  => 'Company Registration',
    'attestation_vigilance' => 'Compliance Certificate',
    'rcc'                   => 'Civil Liability Insurance',
    'attestation_assurance' => 'Insurance Certificate',
    'rib'                   => 'RIB',
    'carte_identite'        => 'ID',
    'statuts'               => 'Articles of Association',
    'liasse_fiscale'        => 'Tax Return',
    'bilan'                 => 'Financial Statements',
    'decennale'             => 'Proof of Address',
    'qualibat'              => 'Qualibat Certificate',
    'autre'                 => 'Other'
  }.freeze

  def up
    VALUE_MAPPING.each do |old_value, new_value|
      execute "UPDATE kyc_documents SET document_type = #{connection.quote(new_value)} WHERE document_type = #{connection.quote(old_value)}"
    end
  end

  def down
    VALUE_MAPPING.each do |old_value, new_value|
      execute "UPDATE kyc_documents SET document_type = #{connection.quote(old_value)} WHERE document_type = #{connection.quote(new_value)}"
    end
  end
end
