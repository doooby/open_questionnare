set -e

app_path=$(pwd)
stack_path=$(realpath $app_path/../..)

domain=$1
if [ $1 == "-h" ] || [ -z $domain ]; then
  echo "Usage: <domain>"
  echo "First argument must be your domain."
  exit 1
fi

if [ $(whoami) != "root" ]; then
  echo "this has to be run as root (sudo?)"
  exit 1
fi

# must be called from app root !

data_path=$stack_path/var/letsencrypt
if [ -d $data_path ]; then
  read -p "Looks like you are running this again. Are you sure to replace current SSL certificate? (Y/n):" decision
  [ "$decision" != "Y" ] && exit 0
  rm -rf $data_path
fi

mkdir -p $data_path
echo $domain > $data_path/domain_name

docker run --rm -ti -v $data_path:/etc/letsencrypt -v $app_path:/opt/app -p "80:80" nginx:base bash app/ops/lib/nginx/create_ssl_cert.sh
