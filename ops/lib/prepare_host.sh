name=$1

if [ -z $name ]; then
  echo "Usage: <script> <name>"
  echo "First argument passed is a name of the stack."
  echo "That is used for group name and directory name in /opt."
  exit 1
fi


if [ $(whoami) != "root" ]; then
  echo "this has to be run as root (sudo?)"
  exit 1
fi

set -e

# create group
groupadd $name

stack_path=/opt/$name
echo "--- creating stack path at $stack_path"
# create stack path
mkdir -p $stack_path
# create git repo
repo_path=$stack_path/app.git
git init --bare $repo_path
chown root:"$name" -R $repo_path
find $repo_path -type d | xargs chmod 0770
find $repo_path -type f | xargs chmod 440
echo

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

    cd ../app
    sudo git fetch origin
    sudo git reset --hard origin/master
    echo

    sudo ../build_app

done
EOF
chown root:"$name" $git_hook
chmod 550 $git_hook
echo

echo "--- finished"