#!/bin/sh

REMOTE_DIR='/remote-fs'
PACKAGES_DIR="$REMOTE_DIR/packages"
REPOS='edge test'
REPO_DIR='/repo'

echo '\n==> Building packages'
key_name="$(ls "$REMOTE_DIR"/.secret/*.rsa | head -n 1 | xargs basename)"
packager_privkey="$REMOTE_DIR/.secret/$key_name"

cd $REPO_DIR

repos=''
for repo in $REPOS; do
    if [ -n "$(find $repo -maxdepth 2 -name APKBUILD)" ]; then
       repos="$repos $repo"
    fi
done
[ -n "$repos" ] || { echo 'No repositories found'; exit 0; }

mkdir -p ~/.abuild
#TODO: Shall be moved to a script executed during bulild?
echo "PACKAGER_PRIVKEY=$packager_privkey" > ~/.abuild/abuild.conf

REPODEST=$PACKAGES_DIR buildrepo -a $REPO_DIR -d $PACKAGES_DIR $repos
