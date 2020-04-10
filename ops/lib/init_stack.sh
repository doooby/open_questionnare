set -e

stack_path=$(pwd)
name=$(basename $stack_path)

if [ $(whoami) != "root" ]; then
  echo "this has to be run as root (sudo?)"
  exit 1
fi

stack_conf=ops_stack.conf
touch $stack_conf
echo "STACK_NAME=$name" >> $stack_conf
echo "STACK_PATH=$stack_path" >> $stack_conf
echo "RAILS_ENV=production" >> $stack_conf

git clone --single-branch --branch master .git src
ln -s src/ops/bin bin

mkdir var
mkdir tmp
chown root:"$name" tmp
chmod 0770 tmp

bash src/ops/lib/build_base_images.sh
