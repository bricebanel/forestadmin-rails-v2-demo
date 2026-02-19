class KycDocument < ApplicationRecord
  belongs_to :company

  # Enums
  enum document_type: {
    kbis: 'Company Registration',
    attestation_vigilance: 'Compliance Certificate',
    rcc: 'Civil Liability Insurance',
    attestation_assurance: 'Insurance Certificate',
    rib: 'RIB',
    carte_identite: 'ID',
    statuts: 'Articles of Association',
    liasse_fiscale: 'Tax Return',
    bilan: 'Financial Statements',
    decennale: 'Proof of Address',
    qualibat: 'Qualibat Certificate',
    autre: 'Other'
  }, _prefix: true

  enum status: {
    pending_review: 'pending_review',
    approved: 'approved',
    rejected: 'rejected',
    missing: 'missing',
    expired: 'expired'
  }, _prefix: true

  # Validations
  validates :company_id, presence: true
  validates :document_type, presence: true
  validates :document_url, presence: true, format: { with: URI::regexp(['http', 'https']) }
  validates :status, presence: true

  # Scopes
  scope :pending, -> { where(status: 'pending_review') }
  scope :approved, -> { where(status: 'approved') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :expired, -> { where(status: 'expired') }
end
