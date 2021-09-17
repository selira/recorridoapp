Rails.application.routes.draw do
  root 'home#index'
  resources :alerts
  get 'cities', to: 'alerts#cities'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
