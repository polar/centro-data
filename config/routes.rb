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
end
