export stack_path=$(pwd)

function libops_aquire_dockerignore_lock {
  libops_assert_stack_path

  lock_file=$(realpath .dockerignore)
  [ -f $lock_file ] && libops_fail_with << HEREDOC
Could not acquire ops/docker lock - .dockerignore alread exists
pwd: $stack_path
HEREDOC

  touch $lock_file
  echo $lock_file
}

function libops_assert_stack_path {
  [ -f ops_stack.conf ] && return 0
  libops_fail_with << HEREDOC
Wrong working directory - could not locate ops_stack.conf
pwd: $stack_path
HEREDOC
}

function libops_print {
  if [ "$2" = "title" ]; then
    msg="> $1"
  else
    msg="    $1"
  fi
  echo -e "\033[35m[LIBOPS] [$(date +"%y%m%d %T")]\033[0m $msg"
}

function libops_fail_with {
  echo -e "\033[31m[LIBOPS] FAIL:\033[0m" >> /dev/stderr
  cat /dev/stdin >> /dev/stderr
  exit 1
}

function libops_docker_run {
  libops_assert_stack_path

  # $1 = image
  # $2 = docker opts
  # $3 = command
  cmd="sudo docker run --rm $2 --env-file $stack_path/ops_stack.conf $1 $3"
  libops_print "exec: $cmd"
  $cmd
}
