set -e

source src/ops/lib/libops.sh
mnt_app="-v $stack_path/src:/app"
mnt_gems="-v $stack_path/var/ruby_bundle:/usr/local/bundle"
mnt_node_modules="-v $stack_path/var/node_modules:/app/node_modules"
mnt_fronted="-v $stack_path/var/fronted:/app/frontend/build"

libops_print "release prerequisites" "title"

libops_print "updating ruby gems"
libops_docker_run app:base \
    "$mnt_app $mnt_gems" \
    "bundle install --without development test --quiet"

libops_print "updating node_modules"
libops_docker_run app:base \
    "$mnt_app $mnt_node_modules" \
    "bin/frontend install --silent"

libops_print "compiling frontend"
libops_docker_run app:base \
    "$mnt_app $mnt_node_modules $mnt_fronted" \
    "bin/frontend build --silent --clean"

src/ops/bin/rebuild_image app release
src/ops/bin/rebuild_image nginx release
