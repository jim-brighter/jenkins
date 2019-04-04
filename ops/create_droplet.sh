# $1 = DigitalOcean Auth Token
# $2 = Server color to create (b or g)

curl -X POST \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $1" \
-d '{
    "name": "jenkins-'"$2"'",
    "region": "nyc3",
    "size": "s-1vcpu-3gb",
    "image": "ubuntu-18-04-x64",
    "ssh_keys": [
        22134471, 23526912
    ],
    "monitoring": true,
    "tags": [
        "jenkins-'"$2"'"
    ]
}' \
"https://api.digitalocean.com/v2/droplets"

# use jq to parse json response: script.sh | jq -r '.droplet.id'