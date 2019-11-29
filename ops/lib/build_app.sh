set -e

docker build -t app:base -f ops/app.base.Dockerfile ..
docker run --rm -v $(pwd)/../var/bundle:/usr/local/bundle/ app:base bundle install --without development test --clean --quiet
#docker run --rm -v $(pwd)/../var/node_modules:/app/node_modules app:base yarn install
docker build -t app:build -f ops/app.Dockerfile ..
