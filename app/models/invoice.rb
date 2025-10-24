class Invoice < ApplicationRecord
  # Associations
  belongs_to :company
  belongs_to :project, optional: true
  has_one :factoring_operation, dependent: :destroy

  # Validations
  validates :invoice_number, presence: true, length: { maximum: 100 }, uniqueness: true
  validates :invoice_type, presence: true, length: { maximum: 50 }
  validates :invoice_date, presence: true
  validates :due_date, presence: true
  validates :amount_ht, presence: true, numericality: { greater_than: 0 }
  validates :amount_ttc, presence: true, numericality: { greater_than: 0 }
  validates :vat_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :chorus_pro_status, length: { maximum: 50 }, allow_blank: true
  validates :chorus_pro_id, length: { maximum: 100 }, uniqueness: true, allow_blank: true
  validate :due_date_after_invoice_date
  validate :vat_calculation

  # Enums
  enum payment_status: {
    pending: 'pending',
    paid: 'paid',
    overdue: 'overdue',
    partially_paid: 'partially_paid',
    cancelled: 'cancelled'
  }, _prefix: true

  enum invoice_type: {
    acompte: 'acompte',               # Down payment / advance payment
    situation: 'situation',            # Progress invoice
    solde: 'solde',                   # Final payment
    avoir: 'avoir'                    # Credit note
  }, _prefix: true

  enum chorus_pro_status: {
    draft: 'draft',
    submitted: 'submitted',
    validated: 'validated',
    rejected: 'rejected',
    paid_chorus: 'paid_chorus'
  }, _prefix: true, _suffix: true

  # Scopes
  scope :unpaid, -> { where(payment_status: ['pending', 'overdue']) }
  scope :overdue, -> { where('due_date < ? AND payment_status IN (?)', Date.today, ['pending', 'overdue']) }
  scope :eligible_for_factoring, -> { where(payment_status: 'pending').where('amount_ttc >= ?', 1000) }
  scope :chorus_pro_pending, -> { where(chorus_pro_status: ['draft', 'submitted']) }

  # Callbacks
  before_validation :calculate_payment_delay, if: :paid_at_changed?
  before_validation :update_payment_status_if_overdue

  # Instance methods
  def days_until_due
    (due_date - Date.today).to_i
  end

  def is_overdue?
    due_date < Date.today && payment_status_pending?
  end

  def can_be_factored?
    payment_status_pending? && amount_ttc >= 1000 && factoring_operation.nil?
  end

  def factored?
    factoring_operation.present?
  end

  def payment_term_days
    (due_date - invoice_date).to_i
  end

  private

  def due_date_after_invoice_date
    return if invoice_date.blank? || due_date.blank?

    if due_date < invoice_date
      errors.add(:due_date, "must be after invoice date")
    end
  end

  def vat_calculation
    return if amount_ht.blank? || vat_amount.blank? || amount_ttc.blank?

    expected_ttc = amount_ht + vat_amount
    if (amount_ttc - expected_ttc).abs > 0.01
      errors.add(:amount_ttc, "must equal amount_ht + vat_amount")
    end
  end

  def calculate_payment_delay
    return unless paid_at && due_date

    self.payment_delay_days = (paid_at.to_date - due_date).to_i
  end

  def update_payment_status_if_overdue
    if due_date && due_date < Date.today && payment_status == 'pending'
      self.payment_status = 'overdue'
    end
  end
end
