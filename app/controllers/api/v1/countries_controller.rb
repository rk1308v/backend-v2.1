class Api::V1::CountriesController < Api::V1::BaseController
    before_action :set_country, only: [:show, :update, :destroy]
    skip_before_action :authenticate_user_from_token!, :only => [:states, :index, :smx_countries, :country_info, :countries_info, :flag, :update_flag]

    #before_action :validate_api_key, only: [:index, :states]

    def_param_group :country do
        param :country, Hash, required: true, action_aware: true do
            param :name, String, required: true, allow_nil: false
        end
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Get Countries
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :GET, '/countries','List Countries'
    
    def index
        country_names = []
        if params.has_key?(:recepient_countries)
            country_names = Country.all.pluck(:name).sort
        else
            country_names = smx_countries_arr.sort
        end
        countries = Array.new
        country_names.each do |c_name|
            c = ISO3166::Country.find_country_by_name c_name
            if c
                country = Country.find_by_iso_alpha_3 c.alpha3
                if country
                    countries << {name: c.name, alpha_code: c.alpha3, country_code: c.country_code, phone_number_lengths:c.national_number_lengths.first, flag: country.flag.url(:micro)}
                end
            end
        end
        render status: 200, json: {countries: countries}
    end

    api :GET, '/states', 'List States'
    def states
        if params.has_key?(:country) && country_params.has_key?(:c) && country_params[:c].present?
            country = ISO3166::Country.find_country_by_alpha3 country_params[:c]
            if country.present?
                states_data = Array.new
                if country.alpha3 == 'USA'
                    country.states.each do |state|
                        if Rails.env == 'production' 
                            states_data << 'New York'
                        else
                            states_data << {name: state[1][:name]}
                        end
                    end
                end
                render status: 200, json: {status: 200, states: states_data}
            else
                render status: 404, json: {status: 404, error: 'Country not found'}
            end
        else
            render status: 404, json: {status: 404, error: 'Country parameter required'}
        end
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Get info of multiple countries
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :GET, '/countries_info','List Countries with info'
    param_group :country
    def countries_info
        countries = ISO3166::Country.all.map do |c|
            { name: c.name, alpha_code: c.alpha3, country_code: c.country_code, phone_number_lengths:c.national_number_lengths.first }
        end
        render status: 200, json: {countries: countries}
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Get info for country whose name is provided
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :GET, '/country_info/:name','Return Country info'
    def country_info
        c = ISO3166::Country.find_country_by_name params[:name]
        country = Country.find_by_iso_alpha_3 c.alpha3
        if c
            country = Country.find_by_iso_alpha_3 c.alpha3
            if country
                country = {name: c.name, alpha_code: c.alpha3, country_code: c.country_code, phone_number_lengths:c.national_number_lengths.first, flag: country.flag.url(:micro)}
                render status: 200, json: {country: country}
            else
                render status: 404, json: {error: "Country not supported"}
            end
        else
            render status: 404, json: {error: "Country not found"}
        end
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Get list of smx countries
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :GET, '/smx_countries','List SMX Countries'
    def smx_countries
        #c = ISO3166::Country.new('us')
        #@country = Country.create!(iso_alpha_3: c.alpha3, name: c.name, susu: true, transfer: true)
        #c = ISO3166::Country.new('bf')
        #@country = Country.create!(iso_alpha_3: c.alpha3, name: c.name, susu: true, transfer: true)
        #render json: @country
        #return
        @countries = Country.all
        render json: {smx_countries: @countries}
    end

    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Update picture using mulipart image
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :PATCH, '/update_flag','Update flag'
    #param_group :country
    def update_flag 
        # render json: country_params[:name]#Country.all
        # return
        c = ISO3166::Country.find_country_by_name country_params[:name]
        if c
            @country = Country.find_by_iso_alpha_3 c.alpha3
            if @country.present?
                @country.update_attribute("flag", country_params[:flag])
                render json: { message: "Flag successfully updated" }
            else 
                @country = Country.new(name: c.name, iso_alpha_3: c.alpha3, transfer: true, susu: true, flag: country_params[:flag])
                @country.save
                render json: { message: "Flag successfully created with country" }
            end
        else
            render status: 404, json: { message: "Country not found" }
        end
    end


    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    #    Get profile picture - small size
    # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
    api :GET, '/flag','Flag'
    def flag
        country = Country.find_by_name params[:name]
        if country
            flag = country.flag.url(:micro)
            if flag.present?
                render json: {updated_at: country.updated_at, flag: flag}
            else 
                render status: 404, json: {message: "Image not present" }
            end
        else
            render status: 404, json: {message: "Country not supported" }
        end
    end

  #api :GET, '/countries/:id','Show Country'
    def show
        render json: @country
    end

    #api :POST, '/countries','Create Country'
    #param_group :country
    def create
        @country = Country.new(country_params)
        if @country.save
            render json: @country, status: :created
        else
            render json: @country.errors, status: :unprocessable_entity
        end
    end

    #api :PUT, '/countries/:id','Update Country'
    #param_group :country
    def update
        if @country.update(country_params)
            render json: @country
        else
            render json: @country.errors, status: :unprocessable_entity
        end
    end

    #api :DELETE, '/countries/:id','Destroy Country'
    # DELETE /countries/1
    def destroy
        @country.destroy
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_country
        @country = Country.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def country_params
        params.require(:country).permit(:name, :flag, :c)
    end

    def smx_countries_arr
        # ["Burkina Faso", "United States"]
        if Rails.env == 'production'
            ["United States"]
        else
            (europe + africa + americas).sort
        end
        
    end

    # def validate_api_key
    #     api_key = request.headers['X-API-APIKEY']
    #     if api_key.blank? || api_key != ENV['USER_API_KEY']
    #         render status: 401, json: {status: 401, error: "API key not authentic", message: 'API key not authentic'}
    #     end
    # end

    def europe
        [
            "Austria",
            "Belgium",
            "Czech Republic",
            "Switzerland",
            "Germany",
            "Denmark",
            "Spain",
            "France",
            "United Kingdom",
            "Greece",
            "Croatia",
            "Hungary",
            "Finland",
            "Ireland",
            "Italy",
            "Luxembourg",
            "Netherlands",
            "Norway",
            "Poland",
            "Romania",
            "Portugal",
            "Russia",
            "Sweden",
            "Ukraine"
        ]
    end 

    def americas
        [
            "Argentina",
            "Brazil",
            "Bahamas",
            "Canada",
            "Chile",
            "Colombia",
            "Costa Rica",
            "Cuba",
            "Dominican Republic",
            "Ecuador",
            "Guadeloupe",
            "Guatemala",
            "Guyana",
            "Haiti",
            "Jamaica",
            "Mexico",
            "Panama",
            "Peru",
            "Puerto Rico",
            "Paraguay",
            "United States of America",
            "Uruguay",
            "Venezuela"
        ]
    end

    def africa
        [
            "Angola",
            "Burkina Faso",
            "Burundi",
            "Benin",
            "Botswana",
            "Congo [DRC]",
            "Central African Republic",
            "Congo",
            "Côte D'Ivoire",
            "Cameroon",
            "Djibouti",
            "Algeria",
            "Egypt",
            "Eritrea",
            "Ethiopia",
            "Gabon",
            "Ghana",
            "Gambia",
            "Guinea",
            "Equatorial Guinea",
            "Guinea-Bissau",
            "Kenya",
            "Liberia",
            "Lesotho",
            "Libya",
            "Morocco",
            "Madagascar",
            "Mali",
            "Mauritania",
            "Malawi",
            "Mozambique",
            "Namibia",
            "Niger",
            "Nigeria",
            "Rwanda",
            "Sudan",
            "Sierra Leone",
            "Senegal",
            "Somalia",
            "South Sudan",
            "Swaziland",
            "Chad",
            "Togo",
            "Tunisia",
            "Tanzania",
            "Uganda",
            "South Africa",
            "Zambia",
            "Zimbabwe"
        ]
    end

    def asia
        [
            "China",
            "Hong Kong",
            "Indonesia",
            "Israel",
            "India",
            "Iraq",
            "Japan",
            "Malaysia",
            "Palestine",
            "Saudi Arabia",
            "Singapore",
            "Syria",
            "Thailand",
            "Turkey",
            "Taiwan",
            "Vietnam"
        ]
    end
end
