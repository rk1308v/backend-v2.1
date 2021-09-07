class TransferNotification < ApplicationRecord
    enum notice_type: [:send_, :request_, :declined_request]
    # Relationships
  
    # It was changed from "belongs_to :transaction" to address the error:                     #
    #                                                                                         #
    # You tried to define an association named transaction on the model TransferNotification, #
    # but this will conflict with a method transaction already defined by Active Record.      #
    # Please choose a different association name.                                             #
    #                                                                                         #
    # We may need to change the name of "Transaction" model                                   #
    #                                                                                         #
    # belongs_to :transaction
    #belongs_to :smx_transaction, class_name: "Transaction" 
  
    # No has_many counterpart defined because we dont anticipate accessing this model from smx_transaction model
    # 03/25/2017 -  Need to Change it to user_transaction??
    # belongs_to :smx_transaction
  
    # No has_many counterpart defined because we dont anticipate accessing this model from user model
    belongs_to :notified_by, class_name: 'User'
    has_many :notifications, as: :noticeable

end
