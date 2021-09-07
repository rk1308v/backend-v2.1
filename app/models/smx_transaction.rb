class SmxTransaction < ApplicationRecord

    include GlobalEnums
    serialize :descriptions, Array
  
    # Relationships
    belongs_to :transactionable, polymorphic: true
  
    # Validation
    validates :amount, presence: true

    def self.status_string input
  	    if input == self.statuses[:pending_]
  		    "Pending"
  	    elsif input == self.statuses[:cancelled_]
  		    "Cancelled"
  	    elsif input == self.statuses[:completed_]
            "Completed"
        elsif input == self.statuses[:queued_]
            'Queued'
  	    end
    end
  
end
