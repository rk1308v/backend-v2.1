class AddAttachmentAvatarToPictures < ActiveRecord::Migration[6.1]
  def self.up
    change_table :pictures do |t|
      t.attachment :avatar
    end
  end

  def self.down
    remove_attachment :pictures, :avatar
  end
end
