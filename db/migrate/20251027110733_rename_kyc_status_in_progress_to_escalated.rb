class RenameKycStatusInProgressToEscalated < ActiveRecord::Migration[7.2]
  def up
    # Update all existing 'in_progress' kyc_status values to 'escalated'
    Company.where(kyc_status: 'in_progress').update_all(kyc_status: 'escalated')
  end

  def down
    # Rollback: change 'escalated' back to 'in_progress'
    Company.where(kyc_status: 'escalated').update_all(kyc_status: 'in_progress')
  end
end
