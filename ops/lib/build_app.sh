set -e

app_path=$(pwd)
lib_path=$(realpath $app_path/..)

echo "running: bundle install"
docker run --rm -v $app_path:/app -v $lib_path/bundle:/usr/local/bundle/ app:base bundle install --without development test --clean --quiet

echo "building: app image"
docker build -t app:build -f ops/docker/app.build.Dockerfile $lib_path

echo "running: frontend build"
docker run --rm -v $lib_path/www:/var/www -v $lib_path/node_modules:/app/app/frontend/node_modules app:build bash -c "cd app/frontend && yarn install && yarn build && cp -R ../../public/* /var/www"

echo "building: nginx"
docker build -t nginx:build -f ops/docker/nginx.build.Dockerfile $lib_path
