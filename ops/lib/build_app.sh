set -e

app_path=$(pwd)
lib_path=$(realpath $app_path/..)

echo "running: bundle install"
docker run --rm -v $app_path:/app -v $lib_path/bundle:/usr/local/bundle/ app:base bundle install --without development test --clean --quiet

echo "building: production code app image"
docker build -t app:production -f ops/docker/app.production.Dockerfile $lib_path

echo "running: build rails assets"
docker run --rm -v $lib_path/www:/var/www -v $lib_path/assets:/app/public/assets app:production bash -c "cp -R public/* /var/www && bin/rails assets:precompile assets:clean"

echo "running: frontend build"
docker run --rm -v $lib_path/frontend/build:/app/public -v $lib_path/frontend:/var/frontend -v $lib_path/frontend/node_modules:/app/app/frontend/node_modules app:production bash -c "rm -rf app/public/* && bash ops/lib/frontend/build.sh"

echo "building: app"
docker build -t app:build -f ops/docker/app.build.Dockerfile $lib_path

echo "building: nginx"
docker build -t nginx:build -f ops/docker/nginx.build.Dockerfile $lib_path
