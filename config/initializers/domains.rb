hosts = ENV['HOST_NAMES']
if hosts
  hosts = hosts.split ' '
  hosts.map!{|name| name.presence&.strip }
  hosts.compact!
  Rails.application.config.hosts += hosts unless hosts.empty?
end
