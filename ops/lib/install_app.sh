set -e

if [ $(whoami) != "root" ]; then
  echo "this has to be run as root (sudo?)"
  exit 1
fi

# must be called from app root
ops_dir=$1
$ops_dir/bin/compose build --pull
$ops_dir/bin/compose run --rm app bundle install
#$ops_dir/bin/compose run --rm app yarn install
