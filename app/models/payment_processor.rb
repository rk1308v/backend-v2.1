class PaymentProcessor < ApplicationRecord

  	# Relationships
  	# belongs_to :country

  	# Validations
  	# validates :country_id, presence: true

  	validate :live_processor
  	scope :live, -> {
  		where(:is_live => true)
	}

	def live_processor
    	if is_live && PaymentProcessor.live.count > 0
       		errors.add(:name, "Another processor is already live!")
    	end
  	end

end
