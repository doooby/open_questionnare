module CommonActions
  extend ActiveSupport::Concern

  included do

    attr_reader :current_user

    rescue_from StandardError do |exception|
      log_fail exception

      if request.format.html?
        render body: Rails.root.join('app/views/pages/500.html').read,
            content_type: 'text/html', status: 500

      else
        render status: 500, json: {ok: false, reason: 'server_fail'}

      end
    end

  end

  def render_ok **data
    data[:ok] = true
    render json: data
  end

  def render_fail reason, **data
    data[:ok] = false
    data[:reason] = reason
    render json: data
  end

  def render_not_found klass
    name = I18n.t "models.#{klass.name.downcase}.name"
    message = I18n.t 'activerecord.exceptions.not_found', klass: name
    render_fail message
  end

  def render_model_errors model
    render_fail 'invalid', errors: model.errors.full_messages
  end

  def render_ok_message translation, **options
    render_ok message: I18n.t(translation, **options)
  end

  private

  def warden_custom_data= data
    request.env['warden.custom_data'] = data
  end

  def authenticate strategy=:password
    @current_user = request.env['warden'].authenticate strategy
  end

  def log_fail exception
    Rails.logger.error <<EXCEPTION
  \033[0;31mFAIL: #{exception.class.name}\033[0m
#{exception.message}
#{Rails.backtrace_cleaner.clean(exception.backtrace).join "\n"}
EXCEPTION
  end

end
