class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception

  def spa
    index_html = Rails.root.join 'public/index.html'
    if index_html.exist?
      render file: index_html
    else
      render plain: 'no frontend app present'
    end
  end

  def authn_fail
    message = 'authentication failed'
    respond_to do |format|
      format.json { render json: {ok: false, reason: message} }
      format.any { render plain: message }
    end
  end

end
