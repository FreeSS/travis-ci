require 'patches/rails_route_set'

TravisCi::Application.routes.draw do
  root :to => 'home#index'

  match ":owner_name/:name.png", :to => 'repositories#show', :format => 'png'
  match ":owner_name/:name.xml", :to => 'repositories#show', :format => 'xml'
  match ":owner_name/:name.json", :to => 'repositories#show', :format => 'json'

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  as :user do
    get 'users/sign_out', :to => 'devise/sessions#destroy', :as => :destroy_session
  end

  resources :repositories, :only => [:index, :show] do
    resources :builds, :except => [:new, :edit, :destroy]
  end

  resources :builds, :only => [:show, :create, :update] do
    put 'log', :on => :member, :as => :log
  end

  resources :tests,   :only => :show
  resources :jobs,    :only => :index
  resources :workers, :only => :index

  resource :profile, :only => :show do
    get :service_hooks, :to => 'service_hooks#index'
    put :service_hooks, :to => 'service_hooks#update'
  end

  match "/stats" => "statistics#index"

  # need to include the jammit route here so it preceeds the user route below
  match "/#{Jammit.package_path}/:package.:extension", :to => 'jammit#package', :as => :jammit, :constraints => { :extension => /.+/ }
end

# we want these after everything else is loaded
TravisCi::Application.routes.append do
  match ":user",                        :to => redirect("/#!/%{user}"),                            :as => :user_redirect
  match ":user/:repository",            :to => redirect("/#!/%{user}/%{repository}"),              :as => :user_repo_redirect
  match ":user/:repository/builds",     :to => redirect("/#!/%{user}/%{repository}/builds"),       :as => :user_repo_builds_redirect
  match ":user/:repository/builds/:id", :to => redirect("/#!/%{user}/%{repository}/builds/%{id}"), :as => :user_repo_build_redirect
end
