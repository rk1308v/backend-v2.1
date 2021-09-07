class HomeController < ApplicationController
    def index
        render file: Rails.root.join('public', 'index.html')
    end

    def exchange_rate_upload
        render 'public/index.html', layout: false
    end
end
