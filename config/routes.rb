Rails.application.routes.draw do
  resources :places
  get 'distance' => 'places#distance'
  get 'search' => 'places#search'
end
