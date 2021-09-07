class ContactBook < ApplicationRecord
    
 # Relationships
 belongs_to :user
    
 # Validations
 validates :user_id, presence: true
 #validates :name, uniqueness: { scope: [:telephone, :email, :user_id] }
 validates :email, uniqueness: { scope: [:user_id], allow_blank: true}
 validates :telephone, uniqueness: { scope: [:user_id], allow_blank: true}
end
