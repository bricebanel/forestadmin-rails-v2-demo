class AccountTransaction < ApplicationRecord
  # Associations
  belongs_to :company

  # Validations
  validates :transaction_type, presence: true, length: { maximum: 50 }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :direction, presence: true, length: { maximum: 10 }
  validates :balance_after, presence: true, numericality: true
  validates :description, length: { maximum: 500 }, allow_blank: true
  validates :reference_type, length: { maximum: 50 }, allow_blank: true

  # Enums
  enum transaction_type: {
    factoring_advance: 'factoring_advance',           # Avance d'affacturage
    factoring_fee: 'factoring_fee',                   # Frais d'affacturage
    factoring_completion: 'factoring_completion',     # Solde d'affacturage
    guarantee_fee: 'guarantee_fee',                   # Frais de garantie
    guarantee_release: 'guarantee_release',           # Libération de garantie
    deposit: 'deposit',                               # Dépôt
    withdrawal: 'withdrawal',                         # Retrait
    transfer_in: 'transfer_in',                       # Virement entrant
    transfer_out: 'transfer_out',                     # Virement sortant
    adjustment: 'adjustment'                          # Ajustement
  }, _prefix: true

  enum direction: {
    credit: 'credit',   # Money coming in (increases balance)
    debit: 'debit'      # Money going out (decreases balance)
  }, _prefix: true

  # Scopes
  scope :credits, -> { where(direction: 'credit') }
  scope :debits, -> { where(direction: 'debit') }
  scope :recent, -> { order(transaction_date: :desc) }
  scope :for_period, ->(start_date, end_date) { where(transaction_date: start_date..end_date) }
  scope :factoring_related, -> { where(transaction_type: ['factoring_advance', 'factoring_fee', 'factoring_completion']) }
  scope :guarantee_related, -> { where(transaction_type: ['guarantee_fee', 'guarantee_release']) }

  # Callbacks
  before_validation :set_transaction_date, on: :create

  # Instance methods
  def self.create_factoring_advance!(company:, factoring_operation:, amount:, balance_before:)
    create!(
      company: company,
      transaction_type: 'factoring_advance',
      amount: amount,
      direction: 'credit',
      balance_after: balance_before + amount,
      description: "Avance d'affacturage - Facture ##{factoring_operation.invoice.invoice_number}",
      reference_type: 'FactoringOperation',
      reference_id: factoring_operation.id
    )
  end

  def self.create_factoring_fee!(company:, factoring_operation:, amount:, balance_before:)
    create!(
      company: company,
      transaction_type: 'factoring_fee',
      amount: amount,
      direction: 'debit',
      balance_after: balance_before - amount,
      description: "Frais d'affacturage - Facture ##{factoring_operation.invoice.invoice_number}",
      reference_type: 'FactoringOperation',
      reference_id: factoring_operation.id
    )
  end

  def self.create_guarantee_fee!(company:, retention_guarantee:, amount:, balance_before:)
    create!(
      company: company,
      transaction_type: 'guarantee_fee',
      amount: amount,
      direction: 'debit',
      balance_after: balance_before - amount,
      description: "Frais de garantie - #{retention_guarantee.guarantee_type}",
      reference_type: 'RetentionGuarantee',
      reference_id: retention_guarantee.id
    )
  end

  def reference_object
    return nil unless reference_type && reference_id
    reference_type.constantize.find_by(id: reference_id)
  end

  def formatted_amount
    direction_credit? ? "+#{amount}" : "-#{amount}"
  end

  private

  def set_transaction_date
    self.transaction_date ||= Time.current
  end
end
