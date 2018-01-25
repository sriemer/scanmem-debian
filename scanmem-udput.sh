#!/bin/bash

PPA="game-cheating-ppa"
PACKAGE="scanmem"

CURBRANCH=`git rev-parse --abbrev-ref HEAD`
UDISTS="trusty xenial artful bionic"

for dist in ${UDISTS}; do
  git checkout ${dist}
  DEBRELS=`cat ${PACKAGE}/debian/changelog | head -n1 | grep -o "(.*)" | tr -d "()"`
  dput "${PPA}" "${PACKAGE}_${DEBRELS}_source.changes"
  git checkout ${CURBRANCH}
done
