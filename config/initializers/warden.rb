
Rails.application.config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :password

  manager.failure_app = ->(env) do
    env['REQUEST_METHOD'] = 'GET'
    ApplicationController.action(:authn_fail).call env
  end
end

Warden::Manager.serialize_into_session do |object|
  object.id
end

Warden::Manager.serialize_from_session do |id|
  User.find_by id: id
end

Warden::Manager.after_authentication do |user, auth, opts|
  user.first_authn_ever = true unless user.last_authn
  user.update_column :last_authn, Time.zone.now
  Rails.logger.info "warden authenticated user: #{user.login}"
end

Warden::Strategies.add :password do
  def custom_data
    @custom_data ||= (env['warden.custom_data'] || {})
  end

  def valid?
    custom_data[:login].present? || custom_data[:password].present?
  end

  def authenticate!
    user = User.find_by login: custom_data[:login], enabled: true
    if user&.password? custom_data[:password]
      success! user
    else
      fail!
    end
  end
end

Warden::Strategies.add :token do
  def token
    @token ||= (env['warden.custom_data'] || '')
  end

  def valid?
    token.present?
  end

  def authenticate!
    user = User.find_by "'#{token}' = ANY (tokens)"
    user ? success!(user) : fail!
  end
end
