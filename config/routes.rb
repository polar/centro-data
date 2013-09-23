CentroData::Application.routes.draw do

  resources :centro_routes do
    member do
      get :download
    end
  end

  resources :jobs do
    collection do
      post :start
      post :stop
    end
  end
  resources :centro_buses

  resources :masters do
    collection do
      post :refresh
    end
    member do
      post :locate
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
