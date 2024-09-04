FROM jenkins/jenkins:lts-alpine-jdk21

USER root

RUN apk update && apk upgrade && \
    apk add nodejs npm docker docker-cli-compose openrc && \
    addgroup jenkins docker && \
    rc-update add docker default

USER jenkins
