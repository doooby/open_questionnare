source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.6'

gem 'rails', '~> 6.0.1'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.3'

gem 'warden'
gem 'bcrypt'
gem 'rack-cors'

gem 'bootsnap', '>= 1.4.2', require: false
gem 'connection_pool'
gem 'patron'
gem 'elasticsearch'
# gem 'jbuilder', '~> 2.7'

gem 'oq_web_plugin', path: File.expand_path('lib/questionnaire/plugin', __dir__)

group :development, :test do
  gem 'byebug'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'webdrivers'
end
