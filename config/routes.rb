CentroData::Application.routes.draw do

  resources :centro_routes do
    member do
      get :download
    end
  end

  namespace :delayed do
    resources :jobs do
      collection do
        post :start
        post :stop
      end
    end
  end
  resources :centro_buses do
    collection do
      get :active
      post :reset
    end
  end

  resources :masters do
    collection do
      post :refresh
    end
    member do
      post :locate
      post :reset
    end
    resources :routes, :controller => "masters/routes" do
      member do
        post :refresh
      end
    end
    resources :journeys, :controller => "masters/journeys" do
      member do
        post :refresh
      end
    end
    resources :patterns, :controller => "masters/patterns"
  end
  resources :apis do
    member do
      post :refresh
      post :login
    end
  end

end
