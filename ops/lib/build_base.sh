set -e

app_path=$(pwd)
stack_lib_path=$(realpath $app_path/..)

docker build -t app:base -f ops/docker/app.base.Dockerfile $stack_lib_path
docker build -t nginx:base -f ops/docker/nginx.base.Dockerfile $stack_lib_path
