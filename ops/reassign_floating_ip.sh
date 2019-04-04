# $1 = DigitalOcean Auth Token
# $2 = Droplet ID to switch to

curl -X POST \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $1" \
-d '{
    "type": "assign",
    "droplet_id": '"$2"'
}' \
"https://api.digitalocean.com/v2/floating_ips/159.203.150.25/actions"
