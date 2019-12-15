name=oquest

if [ $(whoami) != "root" ]; then
  echo "this has to be run as root (sudo?)"
  exit 1
fi

set -e

# create group
groupadd $name

stack_path=/opt/$name
echo "--- preparing stack path at $stack_path"
# create stack path
mkdir $stack_path
chown root:"$name" $stack_path
chmod 750 $stack_path
# lib is a dir for docker images building
mkdir $stack_path/lib

# create git repo
repo_path=$stack_path/app.git
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

    sudo -n true
    sudo_exit=$?
    if [ $sudo_exit -ne 0 ]; then
        echo "user must be sudoer to perform deploy"
        exit 1
    fi

    set -e

    stack_path=$(realpath ..)
    app_path=$stack_path/lib/app

    [ ! -d $app_path ] && exit 0;
    cd $app_path
    sudo git fetch origin
    sudo git reset --hard origin/master
    echo

    builder=$stack_path/build
    [ -f $builder ] && sudo $builder

done
EOF
chown root:"$name" $git_hook
chmod 550 $git_hook

echo "--- finished"