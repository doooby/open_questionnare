set -e

stack_path=$(realpath $1)
name=$(basename $stack_path)

if [ $(whoami) != "root" ]; then
  echo "this has to be run as root (sudo?)"
  exit 1
fi

# create group
groupadd $name

echo "--- preparing stack path at $stack_path"
# create stack path
mkdir $stack_path
cd $stack_path
chown root:"$name" .
chmod 750 .

stack_conf=stack.conf
touch $stack_conf
ln -s $stack_conf .env
echo "STACK_NAME=$name" >> $stack_conf
echo "STACK_PATH=$stack_path" >> $stack_conf
echo "RAILS_ENV=production" >> $stack_conf

mkdir var
mkdir tmp
chown root:"$name" tmp
chmod 0770 tmp

ln -s src/ops/bin bin
ln -s bin/deploy_release release_hook

echo "--- seting up git repository"
# create git repo
repo_path=$stack_path/.git
git init --bare $repo_path
chown root:"$name" -R $repo_path
find $repo_path -type d | xargs chmod 0770
find $repo_path -type f | xargs chmod 440

echo "--- installing git hooks"
# write build hook
git_hook=$repo_path/hooks/post-receive
cat > $git_hook <<"EOF"
#!/bin/bash
while read oldrev newrev refname
do
    set -e

    sudo -n true
    sudo_exit=$?
    if [ $sudo_exit -ne 0 ]; then
        echo "user must be sudoer to perform deploy"
        exit 1
    fi

    stack_path=$(realpath ..)
    working_dir=$stack_path/src

    [ ! -d $working_dir ] && exit 0;
    cd $working_dir
    sudo git fetch origin
    sudo git reset --hard origin/master
    sudo git clean -fdx
    echo

    cd $stack_path
    release_hook=$stack_path/release_hook
    [ -f $release_hook ] && sudo time $release_hook

done
EOF
chown root:"$name" $git_hook
chmod 550 $git_hook

echo "--- finished"