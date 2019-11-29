set -e

if [ $(whoami) != "root" ]; then
  echo "this has to be run as root (sudo?)"
  exit 1
fi

# must be called from app root
ops/bin/compose build --pull
ops/bin/compose run --rm app bundle install
#ops/bin/compose run --rm app yarn install
