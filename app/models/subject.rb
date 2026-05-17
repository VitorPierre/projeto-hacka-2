class Subject < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :proposals

  before_validation { self.name = name&.strip }
  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_destroy :ensure_no_proposals, prepend: true

  private

  def ensure_no_proposals
    if proposals.any?
      errors.add(:base, "Esta especialidade possui propostas de aula vinculadas e não pode ser removida.")
      throw(:abort)
    end
  end
end
