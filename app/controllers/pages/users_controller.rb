module Pages
  class UsersController < Pages::BaseController

    before_action :find_user!, only: %i[change_password disable enable delete]

    # def index
    #   data = User
    #       .all
    #       .order(:enabled)
    #       .map(&:user_pages_data)
    #
    #   render_ok users: data
    # end
    #
    # def collectors
    #   data = User.
    #       where(role: 'collector').
    #       order(:login).
    #       map{|u| {id: u.id, name: u.login}}
    #
    #   render_ok users: data
    # end
    #
    # def create
    #   user = User.create create_params
    #
    #   if user.persisted?
    #     render_ok_message 'models.user.messages.created', login: user.login
    #
    #   else
    #     render_model_errors user
    #
    #   end
    # end
    #
    # def change_password
    #   if @user.update password: params[:password].presence
    #     render_ok_message 'models.user.messages.pass_changed', login: @user.login
    #
    #   else
    #     render_model_errors @user
    #
    #   end
    #
    # end
    #
    # def disable
    #   @user.update_column :enabled, false
    #   render_ok user: @user.user_pages_data,
    #       message: I18n.t('models.user.messages.disabled', login: @user.login)
    # end
    #
    # def enable
    #   @user.update_column :enabled, true
    #   render_ok user: @user.user_pages_data,
    #       message: I18n.t('models.user.messages.enabled', login: @user.login)
    # end
    #
    # def delete
    #   @user.destroy
    #   render_ok_message 'models.user.messages.destroyed', login: @user.login
    # end

    private

    def create_params
      params.require(:user).permit :login, :password, :role
    end

    def find_user!
      id = params[:id.presence]
      @user = (User.find_by id: id if id)
      render_not_found User unless @user
    end

  end
end
