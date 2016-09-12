Rails.application.routes.draw do
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }
  devise_for :hardwares

  resources :credits
  
  resources :events do
    collection do
      get :today
    end

  end
  
  resources :places
  

  resources :instances do
    member do
      get :onetimer
    end
  end

  resources :users do
    member do
      post :link_to_nfc
      get :get_balance
    end
    resources :transfers do
      collection do
        post :send_biathlon
      end
    end
    resources :events
    resources :instances do
      member do
        get :user_attend
      end
    end
  end
      
  resources :authentications do
    collection do
      post :add_provider
    end
  end
  resources :nfcs do
    collection do 
      get :unattached_users
    end
    member do
      get :user_from_tag
    end
  end
  match '/link_temporary_tag' => 'users#link_temporary_tag', via: :post
  match '/users/auth/:provider/callback' => 'authentications#create', :via => :get
  get '/queries/totalSupply'  => 'queries#total_supply'

end
