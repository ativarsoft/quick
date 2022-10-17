#/bin/bash -e
copy_configure_script() {
  cp "configure.scan" "configure.ac"
}

autoscan
if test -f "configure.ac"
then
  echo -n "Create configure.ac? [y/N] "
  if test "$(read)" = "y"
  then
    echo "Copying 'configure.scan' over 'configure.ac'..."
    copy_configure_script
  fi
elif test -e "configure.ac"
then
  echo "The node configure.ac is not a regular file."
  exit
else
  copy_configure_script
fi
touch NEWS
touch README
touch AUTHORS
touch ChangeLog
touch "config.h.in"
aclocal
autoconf
automake --add-missing
