require 'csv'
class Country < ApplicationRecord

    # Relationships
    has_many :addresses
    has_many :payment_methods
    has_many :payment_processors
    has_many :sender_fees_and_commissions, class_name: 'FeesAndCommission', foreign_key: 'sending_country_id'
    has_many :recipient_fees_and_commissions, class_name: 'FeesAndCommission', foreign_key: 'receiving_country_id'
    has_many :payment_organisations, class_name: 'PaymentOrganisation'

    # File Upload
    has_attached_file :flag,
                    styles: {micro: '48x48>', preview: '300x300>',  square: '200x200#', thumb: '100x100>' },
                    s3_permissions: :private,
                    path: 'images/:class/:attachment/:id/:style.:extension',
                    #default_url: 'https://smx-image-bucket.s3-website-us-west-2.amazonaws.com/images/:attachment/default/missing_:style.png'
                    default_url: 'https://s3-us-west-2.amazonaws.com/smx-image-bucket/images/countries/:attachment/default/missing_:style.png'

    # Validations
    validates_attachment_content_type :flag, content_type: /\Aimage\/.*\z/
    validates :iso_alpha_3, presence: true, uniqueness: true
    validates :name, presence: true

    def self.validate_country country
        c = ISO3166::Country.find_country_by_name(country)
        if !c
            "Invalid country full name '#{country}'"
        end    
    end

end
