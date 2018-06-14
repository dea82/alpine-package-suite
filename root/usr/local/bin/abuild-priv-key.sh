#!/bin/sh

REMOTE_DIR='/remote-fs'
key_name="$(ls "$REMOTE_DIR"/.secret/*.rsa | head -n 1 | xargs basename)"
packager_privkey="$REMOTE_DIR/.secret/$key_name"
mkdir -p ~/.abuild
#TODO: Shall be moved to a script executed during build? Make .abuild a volume otherwise?
echo "PACKAGER_PRIVKEY=$packager_privkey" > ~/.abuild/abuild.conf
