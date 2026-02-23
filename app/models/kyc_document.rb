class KycDocument < ApplicationRecord
  belongs_to :company

  # Enums
  enum document_type: {
    company_registration: 'Company Registration',
    compliance_certificate: 'Compliance Certificate',
    civil_liability_insurance: 'Civil Liability Insurance',
    insurance_certificate: 'Insurance Certificate',
    rib: 'RIB',
    id_document: 'ID',
    articles_of_association: 'Articles of Association',
    tax_return: 'Tax Return',
    financial_statements: 'Financial Statements',
    proof_of_address: 'Proof of Address',
    qualibat_certificate: 'Qualibat Certificate',
    other: 'Other'
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
