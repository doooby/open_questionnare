set -e

bundle install
rails assets:precompile
rails db:migrate
