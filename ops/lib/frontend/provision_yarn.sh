set -e

cd app/frontend
mount=/var/frontend

# reuse yarn.lock
if [ -f $mount/yarn.orig.lock ]; then
  no_diff=$(bash -c "comp -s $mount/yarn.orig.lock yarn.lock && echo 1")
  if [ $no_diff == 1 ]; then
    cp $mount/yarn.lock yarn.lock
  else
    cp yarn.lock $mount/yarn.orig.lock
  fi

else
  cp yarn.lock $mount/yarn.orig.lock

fi

built=$(bash -c "$1 && echo 1")
[ $built != 1] && exit 1

cp yarn.lock $mount/yarn.lock
