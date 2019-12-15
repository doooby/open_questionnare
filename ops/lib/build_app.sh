set -e

app_path=$(pwd)
lib_path=$(realpath $app_path/..)

echo "running: bundle install"
docker run --rm -v $app_path:/app -v $lib_path/bundle:/usr/local/bundle/ app:base bundle install --without development test --clean --quiet

echo "building: production code app image"
docker build -t app:production -f ops/docker/app.production.Dockerfile $lib_path

echo "running: frontend build"
rm -rf $lib_path/www/*
docker run --rm -v $lib_path/www:/var/www -v $lib_path/frontend:/var/frontend -v $lib_path/frontend/node_modules app:production bash -c "cp -R public/* /var/www && bash ops/lib/frontend/build.sh && cp -R public/* /var/www"

echo "building: app"
docker build -t app:build -f ops/docker/app.build.Dockerfile $lib_path

echo "building: nginx"
docker build -t nginx:build -f ops/docker/nginx.build.Dockerfile $lib_path
