set -e

ops_dir=$1

docker build $ops_dir/app.base.Dockerfile -t app:base
docker run --rm -v ../var/bundle:/usr/local/bundle/ app:base bundle install --without development test --clean
docker run --rm -v ../var/node_modules:/app/node_modules app:base yarn install
docker build $ops_dir/app.Dockerfile -t app:build
