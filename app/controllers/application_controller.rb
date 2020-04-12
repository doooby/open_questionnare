class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  before_action :redirect_non_www

  def spa
    response.headers['Cache-Control'] = 'no-cache, no-store, must-revalidate'
    response.headers['Pragma'] = 'no-cache'
    response.headers['Expires'] = '0'

    index_html = Rails.root.join 'public/index.html'
    if index_html.exist?
      render file: index_html
    else
      render plain: "no frontend app present\n"
    end
  end

  def authn_fail
    message = 'authentication failed'
    respond_to do |format|
      format.json { render json: {ok: false, reason: message} }
      format.any { render plain: message }
    end
  end

  private

  def redirect_non_www
    puts request.host
    parts = request.host.presence&.split '.'
    if parts.length == 1 && parts.first != 'localhost'
      redirect_to host: "www.#{request.host}", status: 301
    end
  end

end
