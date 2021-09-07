class Picture < ApplicationRecord
   
    # Relationships
    belongs_to :user
  
    # File Upload
    has_attached_file :avatar,
                    styles: {micro: '48x48>', preview: '300x300>',  square: '200x200#', thumb: '100x100>' },
                    s3_permissions: :private,
                    path: 'images/:class/:attachment/:user_id/:style.:extension',
                    default_url: 'https://s3-us-west-2.amazonaws.com/smx-image-bucket/images/pictures/:attachment/default/letters/:user_first_letter_:style.png'
    # Validations
    validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

    def self.parse_avatar avatar_s
        image = Paperclip.io_adapters.for(avatar_s)
    end

    def avatar_url
        self.avatar.url(:thumb)
    end

    def big_avatar_url
        self.avatar.url(:preview)
    end
end