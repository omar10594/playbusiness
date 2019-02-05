Rails.application.routes.draw do
  get 'welcome/index'
  devise_for :users
  resources :startups do
    resources :investments
  end

  root to: 'welcome#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
