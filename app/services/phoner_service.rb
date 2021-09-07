class PhonerService
    def initialize(phone)
        @phone = phone
    end

    def format_number
        if @phone.blank?
            return ''
        else
            pn = nil
            ph_no = "+#{@phone.gsub('+', '')}" if @phone.present?
            if Phoner::Phone.valid? ph_no
                pn = Phoner::Phone.parse(ph_no)
            end
            return pn.nil? ? @phone : pn.format("(+%c) %a-%f-%l")
        end
    end

    def detect_country
        if @phone.blank?
            return ''
        else
            pn = nil
            ph_no = "+#{@phone.gsub('+', '')}" if @phone.present?
            if Phoner::Phone.valid? ph_no
                pn = Phoner::Phone.parse(ph_no)
            end
            if pn.blank?
                return nil
            else
                if pn.country_code == '1'
                    return ISO3166::Country.find_country_by_alpha3('USA')
                else
                    return ISO3166::Country.find_country_by_country_code(pn.country_code)
                end
            end
        end
    end
    
end