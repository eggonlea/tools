#!/bin/bash

date
for REPO in $(find ~/vobs/* -prune -type d); do
  cd ${REPO}
  if [ -e .repo ]; then
    echo "GC ${REPO}..."
    repo forall -j 12 -c 'echo $REPO_PROJECT; git gc'
    date
  fi
done
