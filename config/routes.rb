require 'sidekiq/web'
Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
    apipie
    devise_for :users
    mount Sidekiq::Web, at: "/sidekiq"
    match 'email_link', to: 'email#check_email', via: [:get, :post]
    root to: 'home#index'
    get '/:token/confirm_email/', to: "api/v1/users/registrations#confirm_email", as: 'confirm_email'
    get '/:token/password_update_form/', to: "api/v1/users/registrations#password_update_form", as: 'password_update_form'
    get '/agreements/user/terms_and_conditions', to: redirect('/agreements/user/terms_and_conditions.html')
    get '/agreements/user/privacy_policy', to: redirect('/agreements/user/privacy_policy.html')

    namespace :api do 
        namespace :v1 do 
            devise_scope :user do
                namespace :users, path: '/' do
                    resources :sessions, only: [], path: '/' do
                        collection do 
                            delete :destroy, path: '/logout'
                            post :create, path: '/login'
                            post :reset_password, path: '/reset_password'
                            patch :update_password, path: '/update_password'
                            post :validate_password_code, path: '/validate_password_code'
                            patch :update_password_with_code, path: '/update_password_with_code'
                            post :create, path: 'admin/login'
                        end
                    end
                    resources :registrations, only: [], path: '/' do
                        collection do 
                            post :create, path: '/signup'
                            post :invite_friend, path: '/invite_friends'
                            post :validate_signup_params, path: '/validate_signup_params'
                            post :validate_username, path: '/validate_username'
                            post :update_password, path: '/update_password'
                            post :telephone_verification, path: '/telephone_verification'
                            patch :telephone_verification_update, path: '/telephone_verification_update'
                            patch :change_password, path: '/change_password'
                            patch :update_country, path: '/update_country'
                            patch :update_username, path: '/update_username'
                            patch :update_telephone, path: '/update_telephone'
                            patch :update_email, path: '/update_email'
                            patch :profile_update, path: '/profile_update'
                            patch :update_avatar, path: 'user/update_avatar'
                            post :create, path: 'master/signup'
                            #post :verify_phone_number, path: '/verify_phone_number'
                            #post :send_confirmation_email, path: '/send_confirmation_email'
                            #get :profile, path: '/profile'
                        end
                    end
                end
    
                # Admin routes
                resources :users, only: [], path: '/' do
                    collection do
                        get :basic_stats, path: '/admin/basic_stats'
                        get :user_list, path: '/admin/user_list'
                        get :users_transactions, path: '/admin/transactions'
                    end
                end
            end

            resources :kyc, only: [], path: '/' do
                collection do
                    post :upload_document
                end
            end

            resources :currency_exchanges, only: [], path: '/' do
                collection do
                    post :upload_effective_rates
                end
            end
            
            resources :stripe_charges, only: [], path: '/' do
                collection do
                    post :load_money
                    post :create_stripe_customer
                    post :get_cards
                    post :create_card
                    post :delete_card
                end
            end

            resources :countries do
                collection do
                    get :smx_countries 
                    get :country_info
                    get :countries_info
                    get :flag
                    get :states
                    patch :update_flag
                end
            end
      
            resources :susus do
                collection do
                    post :create_susu 
                    post :send_susu_invite
                    post :update_susu_notification
                    post :susu_pay_in
                    get :susu_list
                    get :susu_details
                end
            end

            resources :user_transactions do
                collection do 
                    post :send_money
                    post :request_money
                end
            end

            # resources :dashboards do 
                #   collection do
                    #     get :notifications
                    #     get :activities
                    #     #get :balance
                    #     post :update_notifications
                #   end
            # end

            resources :pictures do
                collection do
                    get :profile_picture
                    get :big_profile_picture
                    patch :update_picture
                    patch :update_picture_base64
                end
            end

            resources :users do
                collection do 
                    get :get_user
                    get :find_user
                    get :sorted_users
                    get :user_smx_contacts
                    get :user_contacts
                    get :user_non_smx_contacts
                    get :profile
                    get :balance
                    post :sync_contacts
                    get :beneficiaries
                end
            end

            resources :notifications do
                collection do 
                    put :update_notification
                    get :notifications_count
                end
            end

            resources :activities do
                collection do
                    get :friend_activities
                end
            end

            resources :agent_accounts do
                collection do
                    post :signup, to: 'agent_accounts#create_agent'
                    get :agent_addresses
                end
            end

            # once we organize it then the path of the this Api's will change like
            # form /api/v1/post_segovia_params to /api/v1/user_transactions/post_segovia_params
            post 'post_segovia_params', to: 'user_transactions#post_segovia_params'
            get 'states', to: 'countries#states'

            # resources :invite_notifications do
            # end
            
            # resources :susu_notifications do
            # end  
            
            # resources :smx_transactions do
            # end
            
            # resources :user_year_to_dates, only: [:show] do
            # end

            # resources :user_month_to_dates, only: [:show] do
            # end

            # resources :currency_exchanges do
            # end

            # resources :payment_processors do
            # end

            # resources :payment_methods do
            # end

            # resources :user_accounts do
            # end

            # resources :currencies do
            # end
            
            # resources :addresses do
            # end
            
            # resources :susu_invites do
            # end
            
            # resources :susu_memberships do
            # end
            
            # resources :agent_transactions do
            # end
      
            # resources :susu_transactions do
            # end
        
            # resources :admin_transactions do
            # end
      
            # resources :fees_and_commissions do
            # end
      
            # resources :agent_accounts do
            # end
      
            # resources :accounts do
            # end

            # resources :referral_contacts do
            # end

            # resources :transfer_notifications do
            # end
        end
    end 
end

