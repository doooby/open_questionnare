Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  def json_api scope_name, **options, &block
    (options[:defaults] ||= {})[:format] = :json
    (options[:constraints] ||= {})[:format] = :json
    scope scope_name, **options, &block
  end

  def controller controller, as=nil, &block
    as = controller unless as
    scope as, controller: controller, as: as, &block
  end

  ### server rendered full web pages
  root 'application#spa'
  get '/pages/*', to: 'application#spa'

  ### JSON API for pages frontend application
  json_api 'app', as: 'pages' do

    controller 'pages/session', '' do
      post :touch
      post :login
      post :logout
      post :save_language
    end

    controller 'pages/users', 'users' do
    #   get '/', action: 'index'
      get 'collectors'
    #   post '/', action: 'create'
    #   scope '/:id' do
    #     post :change_password
    #     post :disable
    #     post :enable
    #     post :delete
    #   end
    end

    controller 'pages/records', 'records' do
      post :fetch_data
    end

  end

  post '/app/records/download_csv', controller: 'pages/records', action: 'download_csv'

  ### JSON API for android devices
  json_api 'android_api' do

    controller 'android/api', '' do
      post :login
      post :logout
      post :upload
    end

  end

end
