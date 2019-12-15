set -e

cd app/frontend
mount=/var/frontend

reuse_yarn_lock=0
if [ -f $mount/yarn.orig.lock ]; then
  no_diff=$(bash -c "cmp -s $mount/yarn.orig.lock yarn.lock && echo 1")
  [ $no_diff == 1 ] && reuse_yarn_lock=1
fi

if [ $reuse_yarn_lock == 1 ]; then
  cp $mount/yarn.lock yarn.lock
else
  cp yarn.lock $mount/yarn.orig.lock
fi

yarn install
cp yarn.lock $mount/yarn.lock

yarn build
