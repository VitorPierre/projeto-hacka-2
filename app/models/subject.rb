class Subject < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :proposals
  validates :name, presence: true, uniqueness: true
end
