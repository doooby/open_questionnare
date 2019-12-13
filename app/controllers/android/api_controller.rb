module Android
  class ApiController < ActionController::API

    include CommonActions

    before_action :authenticate_using_token, except: %i[login]
    before_action :authorize!, except: %i[login logout]

    def login
      self.warden_custom_data = {
          login: params[:login],
          password: params[:password]
      }
      authenticate

      if current_user
        render_ok login: current_user.login,
            name: current_user.name,
            token: current_user.new_token!

      else
        render json: {
            ok: false,
            reason: 'bad_log_in'
        }

      end
    end

    def logout
      token = params[:token].presence
      current_user&.discard_token! token if token
      render_ok
    end

    def upload
      list = params[:forms].presence

      if list
        list.map!{|rec| rec.tap(&:permit!).to_h }
        Questionnaire.import! list, current_user
      end

      render_ok
    end

    private

    def authenticate_using_token
      self.warden_custom_data = params[:token].presence
      authenticate :token
    end

    def authorize!
      unless current_user
        render json: {
            ok: false,
            reason: 'unauthorized'
        }
      end
    end

  end
end
