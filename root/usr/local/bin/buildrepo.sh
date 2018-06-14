#!/bin/sh

REMOTE_DIR='/remote-fs'
PACKAGES_DIR="$REMOTE_DIR/packages"
REPOS='test'
REPO_DIR='/repos'

echo '\n==> Building packages'

cd $REPO_DIR

repos=''
for repo in $REPOS; do
    if [ -n "$(find $repo -maxdepth 2 -name APKBUILD)" ]; then
       repos="$repos $repo"
    fi
done
[ -n "$repos" ] || { echo 'No repositories found'; exit 0; }

REPODEST=$PACKAGES_DIR buildrepo -a $REPO_DIR -d $PACKAGES_DIR -p $repos
