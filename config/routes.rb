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

    # controller 'pages/session', '' do
    #   post :login
    # end

  end

  ### JSON API for android devices
  json_api 'android_api' do

    controller 'android/api', '' do
      post :login
    end

  end

end
