Apipie.configure do |config|
    config.app_name                = "MoneyApi"
    config.api_base_url            = "/api/v1"
    config.doc_base_url            = "/apipie"
    # where is your API defined?
    config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
    config.validate = false
    config.translate = false
    # set username and password for access api
    config.authenticate = Proc.new do
        authenticate_or_request_with_http_basic do |username, password|
            username == "admin@money-api.com" && password == "Password"
        end
    end
end
