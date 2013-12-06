Skelight::Application.routes.draw do
  
  get 'twitter/stream' => 'twitter#stream'
  
  root 'welcome#index'
end
