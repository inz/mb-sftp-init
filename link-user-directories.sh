#!/bin/bash
#
# Link user directories to mounted volume.

# set -o xtrace

users_dir=/home
link_name=upload

if ! [ -d "$SFTP_VOLUME_BASE_PATH" ]; then
  echo "Set env var SFTP_VOLUME_BASE_PATH to initialize user directories."
  exit 1
fi

for userdir in ${users_dir}/*; do
  username=$(basename $userdir)
  if [ "$username" = "$SFTP_SERVICE_USER" ] ; then
    continue
  fi

  if [ -d "$userdir" ]; then
    path_in_volume="$SFTP_VOLUME_BASE_PATH/$username"
    if ! [ -d "$path_in_volume" ]; then
      echo "Creating user directory $path_in_volume..."
      mkdir -vp "$path_in_volume"
    fi

    link_target="$userdir/$link_name"
    if [ -d "$link_target" ]; then
      rmdir "$link_target"
    fi

    echo "Creating link from $link_target to $path_in_volume..."
    ln -vsfT "$path_in_volume" "$link_target"

    if [ "$SFTP_SERVICE_USER" ]; then
      ln -vsfT "$path_in_volume" "$users_dir/$SFTP_SERVICE_USER/$username"
    fi
  fi
done

echo "Done."
