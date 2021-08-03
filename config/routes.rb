Rails.application.routes.draw do
  post '/sign_up', to: 'auth#sign_up'
  post '/sign_in', to: 'auth#sign_in'
  delete '/sign_out', to: 'auth#sign_out'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
