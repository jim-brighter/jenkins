# $1 = DigitalOcean Auth Token
# $2 = Droplet ID to move

curl -X POST \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $1" \
-d '{
    "resources": [
        "do:droplet:'"$2"'"
    ]
}' \
"https://api.digitalocean.com/v2/projects/f49dc8d4-b71f-4693-9d3d-a0f42e3a99bb/resources"