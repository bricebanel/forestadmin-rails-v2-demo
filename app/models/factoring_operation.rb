class FactoringOperation < ApplicationRecord
  # Associations
  belongs_to :invoice
  belongs_to :company

  # Validations
  validates :invoice_amount, presence: true, numericality: { greater_than: 0 }
  validates :advance_rate, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :advance_amount, presence: true, numericality: { greater_than: 0 }
  validates :fee_rate, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :fee_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :net_amount, presence: true, numericality: { greater_than: 0 }
  validates :approved_by, length: { maximum: 255 }, allow_blank: true
  validates :risk_score, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validate :amounts_calculation

  # Enums
  enum status: {
    pending: 'pending',
    under_review: 'under_review',
    approved: 'approved',
    rejected: 'rejected',
    funded: 'funded',
    completed: 'completed',
    cancelled: 'cancelled'
  }, _prefix: true

  # Scopes
  scope :pending_approval, -> { where(status: ['pending', 'under_review']) }
  scope :active, -> { where(status: ['approved', 'funded']) }
  scope :completed_operations, -> { where(status: 'completed') }
  scope :high_risk, -> { where('risk_score >= ?', 70) }
  scope :awaiting_documents, -> { where(documents_received: false).where(status: ['pending', 'under_review']) }

  # Callbacks
  before_validation :calculate_amounts, if: :should_recalculate_amounts?

  # Instance methods
  def approve!(approver_name)
    return false unless status_pending? || status_under_review?

    update(
      status: 'approved',
      approved_by: approver_name,
      approved_at: Time.current
    )
  end

  def reject!(reason)
    return false unless status_pending? || status_under_review?

    update(
      status: 'rejected',
      rejection_reason: reason
    )
  end

  def fund!
    return false unless status_approved?

    update(
      status: 'funded',
      funded_at: Time.current
    )
  end

  def complete_final_payment!
    return false unless status_funded?

    update(
      status: 'completed',
      final_payment_at: Time.current
    )
  end

  def remaining_amount
    invoice_amount - advance_amount
  end

  def days_since_funding
    return nil unless funded_at
    (Time.current.to_date - funded_at.to_date).to_i
  end

  def is_high_risk?
    risk_score.present? && risk_score >= 70
  end

  def pending_documents?
    !documents_received && (status_pending? || status_under_review?)
  end

  private

  def calculate_amounts
    self.advance_amount = (invoice_amount * advance_rate / 100).round(2)
    self.fee_amount = (invoice_amount * fee_rate / 100).round(2)
    self.net_amount = (advance_amount - fee_amount).round(2)
  end

  def should_recalculate_amounts?
    invoice_amount_changed? || advance_rate_changed? || fee_rate_changed?
  end

  def amounts_calculation
    return if invoice_amount.blank? || advance_rate.blank? || fee_rate.blank?

    expected_advance = (invoice_amount * advance_rate / 100).round(2)
    expected_fee = (invoice_amount * fee_rate / 100).round(2)
    expected_net = (expected_advance - expected_fee).round(2)

    if (advance_amount - expected_advance).abs > 0.01
      errors.add(:advance_amount, "must equal invoice_amount * advance_rate / 100")
    end

    if (fee_amount - expected_fee).abs > 0.01
      errors.add(:fee_amount, "must equal invoice_amount * fee_rate / 100")
    end

    if (net_amount - expected_net).abs > 0.01
      errors.add(:net_amount, "must equal advance_amount - fee_amount")
    end
  end
end
