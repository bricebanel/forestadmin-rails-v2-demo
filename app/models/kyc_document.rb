class KycDocument < ApplicationRecord
  belongs_to :company

  # Enums
  enum document_type: {
    kbis: 'kbis',                                           # Extract K-bis (company registration)
    attestation_vigilance: 'attestation_vigilance',         # URSSAF certificate
    rcc: 'rcc',                                             # RCC (civil liability insurance)
    attestation_assurance: 'attestation_assurance',         # Insurance certificate
    rib: 'rib',                                             # Bank details (RIB)
    carte_identite: 'carte_identite',                       # ID card of legal representative
    statuts: 'statuts',                                     # Company statutes
    liasse_fiscale: 'liasse_fiscale',                       # Tax documents
    bilan: 'bilan',                                         # Financial statements
    decennale: 'decennale',                                 # 10-year insurance (specific to construction)
    qualibat: 'qualibat',                                   # Qualibat certification (construction quality)
    autre: 'autre'                                          # Other documents
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
