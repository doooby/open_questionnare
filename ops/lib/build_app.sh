set -e

app_path=$(pwd)
lib_path=$(realpath $app_path/..)

echo "running: bundle install"
docker run --rm -v $app_path:/app -v $lib_path/bundle:/usr/local/bundle/ app:base bundle install --without development test --clean --quiet
echo "running: yarn install"
docker run --rm -v $app_path:/app -v $lib_path/node_modules:/app/node_modules app:base yarn install

docker build -t app:build -f ops/docker/app.Dockerfile $lib_path
