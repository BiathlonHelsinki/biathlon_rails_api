Rails.application.routes.draw do
  devise_for :users, :controllers => { omniauth_callbacks: 'omniauth_callbacks' }
  devise_for :hardwares

  resources :credits do
    member do
      post :resubmit
    end
  end


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

  resources :groups do
    member do
      get :get_eth_address
      get :get_balance
    end

    resources :transfers do
      collection do
        post :send_biathlon
      end
    end

  end

  resources :users do
    member do
      post :link_to_nfc
      get :get_eth_address
      get :get_balance
      post :check_pin
      post :respend
    end
    resources :userphotoslots do
      collection do
        post :buy_slot
      end
    end

    resources :transfers do
      collection do
        post :send_biathlon
      end
    end
    resources :events
    resources :roombookings
    resources :instances do
      member do
        get :user_attend
      end
    end
  end

  resources :nodes do
    resources :opensessions do
      collection do
        get :open
        get :close
      end
    end
  end
  resource :hardwares do
    collection do
      get :i_am_alive
    end
  end

  resources :stakes do
    member do
      get :award_stake_points
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
      post :verify_tag
    end
    member do
      get :user_from_tag
      post :erase_tag
      get :auth_door
      get :auth_closet
    end
  end
  match '/users/:user_id/instances/:instance_id/user_attend/:visit_date' => 'instances#user_attend', via: :get
  match '/instances/:instance_id/users/:user_id/resubmit/:id' => 'users#resubmit', via: :post
  match '/link_temporary_tag' => 'users#link_temporary_tag', via: :post
  match '/users/auth/:provider/callback' => 'authentications#create', :via => :get
  get '/queries/totalSupply'  => 'queries#total_supply'
  get '/contract_address' => 'queries#contract_address'
end
