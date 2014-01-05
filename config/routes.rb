Skelight::Application.routes.draw do
  
  get 'twitter' => 'twitter#index'
  
  get 'twitter/stream' => 'twitter#stream'
  
  root 'welcome#index'
end
