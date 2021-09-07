class Address < ApplicationRecord
  serialize :descriptions, Array

  # Relationships
  belongs_to :user
  belongs_to :country
  enum address_type: %w(physical pobox)

  # Validations
  validates :user_id, presence: true

end
