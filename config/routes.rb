Rails.application.routes.draw do
  
  root 'home#index'
  #get '/*path', to: 'home#index' 
  namespace :api do
    resources :alerts, only: [:index, :show, :update, :destroy, :create]
    get 'cities', to: 'alerts#cities'
    get 'update_travels/:alert_id', to: 'bus_travels#update' 
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
