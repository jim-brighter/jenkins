#!/bin/bash

set -e

# Authenticate to DigitalOcean
doctl auth init -t $DO_TOKEN

# Initialize variables
OLD_DROPLET=$(doctl compute droplet list 'jenkins*' --format Name | sed -n 2p)
echo "Old Droplet: $OLD_DROPLET"

NEW_DROPLET=$([ $OLD_DROPLET = 'jenkins-g' ] && echo 'jenkins-b' || echo 'jenkins-g')
echo "New Droplet: $NEW_DROPLET"

curl -L -o jenkins-user-data.sh \
https://$GIT_USERNAME:$GIT_PASSWORD@raw.githubusercontent.com/jim-brighter/ops-secrets/master/jenkins/jenkins-user-data.sh

# # Launch new Jenkins droplet
doctl compute droplet create $NEW_DROPLET \
--region nyc3 \
--size s-1vcpu-3gb \
--image 47146497 \
--ssh-keys 22134471,23526912 \
--enable-monitoring \
--tag-names $NEW_DROPLET \
--user-data-file jenkins-user-data.sh \
--wait

# Get ID of new droplet
NEW_DROPLET_ID=$(doctl compute droplet list $NEW_DROPLET --format ID | sed -n 2p)
NEW_DROPLET_IP=$(doctl compute droplet list $NEW_DROPLET --format "Public IPv4" | sed -n 2p)
echo "New Droplet ID: $NEW_DROPLET_ID"

attempts=0
max_attempts=36

until $(curl --output /dev/null --silent --head --fail http://$NEW_DROPLET_IP/login\?from=%2F); do
  
  if [ ${attempts} -eq ${max_attempts} ]; then
    echo "Jenkins failed to respond in a timely manner!"
    exit 1
  fi

  attempts=$(($attempts+1))
  echo "Waiting for Jenkins to respond at http://$NEW_DROPLET_IP ..."
  sleep 10
done

# Reassign jimsjenkins.xyz floating ip to new droplet
doctl compute floating-ip-action assign 159.203.150.25 $NEW_DROPLET_ID

# Move new droplet to jimsjenkins.xyz project
doctl projects resources assign f49dc8d4-b71f-4693-9d3d-a0f42e3a99bb --resource=do:droplet:$NEW_DROPLET_ID
