#!/bin/bash

PACKAGE="scanmem"
CURBRANCH=`git rev-parse --abbrev-ref HEAD`
UDISTS="trusty xenial artful bionic"
CURDIST=`cat debian/changelog | head -n1 | grep -o ").*;" | cut -c 3- | tr -d ';'`

DEBRELS=`cat debian/changelog | head -n1 | grep -o "(.*)" | tr -d "()"`
VERS=`echo "${DEBRELS}" | cut -d '-' -f1`

i=1
for dist in ${UDISTS}; do
  git branch -D ${dist}
  git checkout -b ${dist}
  sed -i s/${DEBRELS}/${DEBRELS}\.${i}/ debian/changelog
  sed -i s/${CURDIST}/${dist}/ debian/changelog
  let "i++"
  git commit -a -m "debian/changelog: Update for ${dist} build"
  mkdir ${PACKAGE}
  git mv debian/ ${PACKAGE}/
  git commit -a -m "Move dir 'debian' into new dir '${PACKAGE}'"
  cd ${PACKAGE}
  uscan --force-download
  git add ../*
  git commit -a -m "Run 'uscan --force-download'"
  tar xzf ../${PACKAGE}-${VERS}.tar.gz
  mv ${PACKAGE}-${VERS}/* .
  mv ${PACKAGE}-${VERS}/.* .
  rmdir ${PACKAGE}-${VERS}
  git add *
  git add .*
  git commit -a -m "Import the code from v${VERS} upstream"
  debuild -S
  git add ../*
  git commit -a -m "Run 'debuild -S'"
  cd ..
  git checkout ${CURBRANCH}
done
