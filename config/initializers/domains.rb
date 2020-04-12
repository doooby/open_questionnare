hosts = ENV['HOST_NAMES'].presence.split ' '
Rails.application.config.hosts += hosts if hosts
