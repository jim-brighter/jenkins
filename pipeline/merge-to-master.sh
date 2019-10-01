#!/bin/bash

git checkout -- .
git checkout master
git merge ${GIT_BRANCH}
git push ${origin} master
