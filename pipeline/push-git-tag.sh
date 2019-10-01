#!/bin/bash

git remote set-url origin https://github.com/jim-brighter/jenkins.git
git config user.name "${GIT_NAME}"
git config user.email ${GIT_EMAIL}
git tag -a ${tag} -m "New Tag ${tag}"
git push ${origin} ${tag}
