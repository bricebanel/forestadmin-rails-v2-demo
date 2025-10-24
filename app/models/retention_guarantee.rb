class RetentionGuarantee < ApplicationRecord
  # Associations
  belongs_to :project_participant
  belongs_to :company

  # Validations
  validates :guarantee_amount, presence: true, numericality: { greater_than: 0 }
  validates :guarantee_type, presence: true, length: { maximum: 50 }
  validates :issue_date, presence: true
  validates :beneficiary, presence: true, length: { maximum: 255 }
  validates :annual_fee_rate, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 100 }
  validates :fee_amount, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :contract_reference, length: { maximum: 255 }, allow_blank: true
  validate :release_date_after_issue_date

  # Enums
  enum status: {
    active: 'active',
    released: 'released',
    expired: 'expired',
    cancelled: 'cancelled'
  }, _prefix: true

  enum guarantee_type: {
    retention: 'retention',                      # Garantie de retenue de garantie
    advance_payment: 'advance_payment',          # Garantie d'acompte
    good_performance: 'good_performance',        # Garantie de bonne exécution
    final_completion: 'final_completion'         # Garantie de parfait achèvement
  }, _prefix: true

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :expiring_soon, -> { where('release_date <= ? AND status = ?', Date.today + 30.days, 'active') }
  scope :overdue_release, -> { where('release_date < ? AND status = ?', Date.today, 'active') }

  # Callbacks
  before_validation :calculate_fee_amount, if: :should_recalculate_fee?
  before_validation :update_status_if_released

  # Instance methods
  def release!
    return false unless status_active?

    update(
      status: 'released',
      release_date: Date.today
    )
  end

  def days_until_release
    return nil unless release_date
    (release_date - Date.today).to_i
  end

  def is_expiring_soon?
    release_date && release_date <= Date.today + 30.days && status_active?
  end

  def is_overdue_for_release?
    release_date && release_date < Date.today && status_active?
  end

  def duration_days
    return nil unless release_date
    (release_date - issue_date).to_i
  end

  def duration_years
    return nil unless duration_days
    (duration_days / 365.0).round(2)
  end

  def total_fees_projected
    return nil unless duration_years
    (guarantee_amount * annual_fee_rate / 100 * duration_years).round(2)
  end

  private

  def calculate_fee_amount
    if duration_years
      self.fee_amount = total_fees_projected
    end
  end

  def should_recalculate_fee?
    guarantee_amount_changed? || annual_fee_rate_changed? || release_date_changed?
  end

  def release_date_after_issue_date
    return if issue_date.blank? || release_date.blank?

    if release_date < issue_date
      errors.add(:release_date, "must be after issue date")
    end
  end

  def update_status_if_released
    if release_date && release_date <= Date.today && status == 'active'
      self.status = 'released'
    end
  end
end
