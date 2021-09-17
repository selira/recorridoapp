Rails.application.routes.draw do
  
  root 'home#index'
  #get '/*path', to: 'home#index' 
  namespace :api do
    resources :alerts
    get 'cities', to: 'alerts#cities'
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
