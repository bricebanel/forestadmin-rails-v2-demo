class Project < ApplicationRecord
  # Associations
  has_many :invoices, dependent: :destroy
  has_many :project_participants, dependent: :destroy
  has_many :companies, through: :project_participants
  has_many :retention_guarantees, through: :project_participants

  # Validations
  validates :project_name, presence: true, length: { maximum: 500 }
  validates :contracting_authority, presence: true, length: { maximum: 255 }
  validates :project_type, length: { maximum: 100 }, allow_blank: true
  validates :location, length: { maximum: 255 }, allow_blank: true
  validates :contracting_authority_type, length: { maximum: 50 }, allow_blank: true
  validates :total_budget_eur, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :progress_percentage, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validate :end_date_after_start_date

  # Enums
  enum status: {
    planned: 'planned',
    in_progress: 'in_progress',
    completed: 'completed',
    suspended: 'suspended',
    cancelled: 'cancelled'
  }, _prefix: true

  enum contracting_authority_type: {
    state: 'state',                    # État
    local_authority: 'local_authority', # Collectivité territoriale
    public_establishment: 'public_establishment', # Établissement public
    private: 'private'                 # Privé
  }, _prefix: true

  # Scopes
  scope :active, -> { where(status: ['planned', 'in_progress']) }
  scope :public_sector, -> { where(contracting_authority_type: ['state', 'local_authority', 'public_establishment']) }
  scope :in_progress, -> { where(status: 'in_progress') }
  scope :overdue, -> { where('expected_end_date < ? AND status = ?', Date.today, 'in_progress') }

  # Instance methods
  def duration_days
    return nil unless start_date && expected_end_date
    (expected_end_date - start_date).to_i
  end

  def actual_duration_days
    return nil unless start_date && actual_end_date
    (actual_end_date - start_date).to_i
  end

  def is_overdue?
    expected_end_date && expected_end_date < Date.today && status == 'in_progress'
  end

  def total_invoiced
    invoices.sum(:amount_ttc)
  end

  def invoicing_rate
    return 0 if total_budget_eur.nil? || total_budget_eur.zero?
    (total_invoiced / total_budget_eur * 100).round(2)
  end

  private

  def end_date_after_start_date
    return if start_date.blank? || expected_end_date.blank?

    if expected_end_date < start_date
      errors.add(:expected_end_date, "must be after start date")
    end
  end
end
