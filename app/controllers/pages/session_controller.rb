module Pages
  class SessionController < Pages::BaseController

    skip_before_action :authenticate, only: %i[login]

    def touch
      render_ok user: (current_user && user_metadata)
    end

    def login
      reset

      self.warden_custom_data = {
          login: params[:login],
          password: params[:password]
      }
      authenticate

      if current_user
        set_user_locale! unless current_user.first_authn_ever # on first login

        render_ok message: I18n.t('sessions.logged_in', login: current_user.name),
            user: user_metadata

      else
        render_fail I18n.t('sessions.bad_id')

      end
    end

    def logout
      if current_user
        render_ok_message 'sessions.logged_out', login: current_user.login

      else
        render_ok

      end

      reset
    end

    def save_language
      set_user_locale!
      render_ok
    end

    private

    def user_metadata
      {
          login: current_user.login,
          language: current_user.language
      }
    end

    def reset
      request.env['warden'].logout
      reset_session
    end

    def set_user_locale!
      locale = params[:locale]
      if Pages::LANGUAGES.include? locale
        I18n.locale = locale
        current_user.update! language: locale
      end
    end

  end
end
