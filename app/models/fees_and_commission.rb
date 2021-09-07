class FeesAndCommission < ApplicationRecord
  include GlobalEnums
  enum fc_type: [:fees, :commission]

  # Relationships
  belongs_to :sending_country, class_name: 'Country'
  belongs_to :receiving_country, class_name: 'Country'
  
  # Validations
  validates :percent_based, presence: true
  validates :sending_country_id, presence: true
  validates :receiving_country_id, presence: true

end
