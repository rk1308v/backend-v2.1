class AddAttachmentKycToUsers < ActiveRecord::Migration[6.1]
  def self.up
    change_table :users do |t|
      t.attachment :kyc
    end
  end

  def self.down
    remove_attachment :users, :kyc
  end
end
