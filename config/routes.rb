Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  get "/up", to: proc { [200, { "Content-Type" => "text/plain" }, ["ok"]] }

  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"

      namespace :admin do
        resources :customers
        resources :vehicles
        resources :catalog_services
        resources :parts
        resources :service_orders, only: %i[index show create update] do
          member do
            post :start_diagnosis
            post :send_budget
            post :finish
            post :deliver
          end
        end
        get "metrics/average_execution_time", to: "metrics#average_execution_time"
      end

      namespace :public do
        resources :service_orders, only: %i[index show], param: :public_token do
          member do
            post :approve
            post :reject
          end
        end
      end
    end
  end
end
