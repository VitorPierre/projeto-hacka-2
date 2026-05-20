class BackfillProposalModalities < ActiveRecord::Migration[8.1]
  def up
    # We use update_all to bypass validation checks and directly write to the database.
    # We set modality to 2 (:focused_mentoring) and duration to 1 (since focused_mentoring requires at least 1 hour).
    Proposal.where(modality: nil).update_all(modality: 2, duration: 1)
    
    # Let's also check if there are any proposals with modality 1 (:express_session), which is no longer active.
    # In case there are, we can leave them or migrate them to focused_mentoring.
    # Since the validation duration_respects_modality adds an error for "express_session",
    # any existing proposals with "express_session" will also fail validations.
    # Let's check if there are any express_session proposals.
    # To be extremely safe, we migrate them to focused_mentoring as well.
    Proposal.where(modality: 1).update_all(modality: 2, duration: 1)
  end

  def down
    # No-op or non-reversible because nil values would violate validations.
  end
end
