#!/bin/bash

docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}
docker push jimbrighter/jenkins:latest
docker push jimbrighter/jenkins-nginx:latest
