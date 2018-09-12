Wmsb::Application.routes.draw do
  root :to => 'sessions#new'
  get '/faq' => 'site#faq'
  post 'login' => 'sessions#create'
  delete 'logout' => 'sessions#destroy'

  get 'session_timeout' => 'sessions#destroy'
  resources :buses, only: :index
end
