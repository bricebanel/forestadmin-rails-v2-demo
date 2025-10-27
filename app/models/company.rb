class Company < ApplicationRecord
  # Associations
  has_many :invoices, dependent: :destroy
  has_many :factoring_operations, dependent: :destroy
  has_many :retention_guarantees, dependent: :destroy
  has_many :account_transactions, dependent: :destroy
  has_many :project_participants, dependent: :destroy
  has_many :projects, through: :project_participants
  has_many :kyc_documents, dependent: :destroy

  # Validations
  validates :company_name, presence: true, length: { maximum: 255 }
  validates :siret, presence: true, length: { is: 14 }, uniqueness: true
  validates :contact_name, presence: true, length: { maximum: 255 }
  validates :contact_email, presence: true, length: { maximum: 255 }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :contact_phone, length: { maximum: 20 }, allow_blank: true
  validates :legal_form, length: { maximum: 50 }, allow_blank: true
  validates :city, length: { maximum: 100 }, allow_blank: true
  validates :postal_code, length: { maximum: 10 }, allow_blank: true
  validates :specialization, length: { maximum: 100 }, allow_blank: true
  validates :iban, length: { maximum: 34 }, allow_blank: true
  validates :credit_limit_eur, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :annual_revenue, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :employee_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  # Enums
  enum status: {
    active: 'active',
    suspended: 'suspended',
    closed: 'closed'
  }, _prefix: true

  enum kyc_status: {
    pending: 'pending',
    escalated: 'escalated',
    waiting_on_customer: 'waiting_on_customer',
    validated: 'validated',
    rejected: 'rejected'
  }, _prefix: true

  enum company_size: {
    tpe: 'tpe',      # Très Petite Entreprise (< 10 employees)
    pme: 'pme',      # Petite et Moyenne Entreprise (10-250 employees)
    eti: 'eti',      # Entreprise de Taille Intermédiaire (250-5000 employees)
    ge: 'ge'         # Grande Entreprise (> 5000 employees)
  }, _prefix: true

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :kyc_validated, -> { where(kyc_status: 'validated') }
  scope :pending_kyc, -> { where(kyc_status: 'pending') }

  # Instance methods
  def account_balance
    account_transactions.order(transaction_date: :desc).first&.balance_after || 0
  end

  def total_factoring_in_progress
    factoring_operations.where(status: 'funded').sum(:advance_amount)
  end

  def available_credit
    return 0 if credit_limit_eur.nil?
    credit_limit_eur - total_factoring_in_progress
  end
end
