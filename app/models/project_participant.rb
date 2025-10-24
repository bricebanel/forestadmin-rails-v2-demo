class ProjectParticipant < ApplicationRecord
  # Associations
  belongs_to :project
  belongs_to :company
  has_many :retention_guarantees, dependent: :destroy

  # Validations
  validates :role, presence: true, length: { maximum: 50 }
  validates :contract_amount_eur, presence: true, numericality: { greater_than: 0 }
  validates :retention_guarantee_amount_eur, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :retention_guarantee_rate, numericality: { greater_than: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :work_scope, length: { maximum: 2000 }, allow_blank: true
  validates :company_id, uniqueness: { scope: [:project_id, :role], message: "already has this role in this project" }

  # Enums
  enum role: {
    general_contractor: 'general_contractor',     # Entrepreneur général
    subcontractor: 'subcontractor',               # Sous-traitant
    prime_contractor: 'prime_contractor',         # Maître d'œuvre
    supplier: 'supplier',                         # Fournisseur
    specialist: 'specialist'                      # Spécialiste (électricité, plomberie, etc.)
  }, _prefix: true

  # Scopes
  scope :contractors, -> { where(role: ['general_contractor', 'prime_contractor']) }
  scope :subcontractors, -> { where(role: 'subcontractor') }
  scope :with_guarantees, -> { where.not(retention_guarantee_amount_eur: nil) }

  # Callbacks
  before_validation :calculate_retention_guarantee_amount, if: :should_recalculate_guarantee?

  # Instance methods
  def has_active_guarantees?
    retention_guarantees.active.any?
  end

  def total_active_guarantee_amount
    retention_guarantees.active.sum(:guarantee_amount)
  end

  def invoiced_amount
    company.invoices.where(project_id: project_id).sum(:amount_ttc)
  end

  def invoicing_progress_percentage
    return 0 if contract_amount_eur.zero?
    (invoiced_amount / contract_amount_eur * 100).round(2)
  end

  def remaining_contract_amount
    contract_amount_eur - invoiced_amount
  end

  def is_behind_schedule?
    # A participant is behind if their invoicing progress is significantly lower than project progress
    return false unless project.progress_percentage
    invoicing_progress_percentage < (project.progress_percentage - 15)
  end

  private

  def calculate_retention_guarantee_amount
    if retention_guarantee_rate && contract_amount_eur
      self.retention_guarantee_amount_eur = (contract_amount_eur * retention_guarantee_rate / 100).round(2)
    end
  end

  def should_recalculate_guarantee?
    contract_amount_eur_changed? || retention_guarantee_rate_changed?
  end
end
