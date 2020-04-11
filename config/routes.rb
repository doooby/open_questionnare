Rails.application.routes.draw do

  def json_api scope_name, **options, &block
    (options[:defaults] ||= {})[:format] = :json
    (options[:constraints] ||= {})[:format] = :json
    scope scope_name, **options, &block
  end

  def controller_scope controller, as=nil, &block
    as = controller unless as
    scope as, controller: controller, as: as, &block
  end

  ### server rendered full web pages
  root 'application#spa'
  get '/pages/*page', to: 'application#spa'

  ### JSON API for pages frontend application
  # json_api 'app', as: 'pages' do

    # controller_scope 'pages/session', '' do
    #   post :touch
    #   post :login
    #   post :logout
    #   post :save_language
    # end

    # controller_scope 'pages/users', 'users' do
    # #   get '/', action: 'index'
    #   get 'collectors'
    # #   post '/', action: 'create'
    # #   scope '/:id' do
    # #     post :change_password
    # #     post :disable
    # #     post :enable
    # #     post :delete
    # #   end
    # end

    # controller_scope 'pages/records', 'records' do
    #   post :fetch_data
    # end

  # end

  # post '/app/records/download_csv', controller: 'pages/records', action: 'download_csv'

  ### JSON API for android devices
  # json_api 'android_api' do
  #
  #   controller_scope 'android/api', '' do
  #     post :login
  #     post :logout
  #     post :upload
  #   end
  #
  # end

end
