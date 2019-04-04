# $1 = DigitalOcean Auth Token
# $2 = Server color to delete (b or g)

curl -X DELETE \
-H "Content-Type: application/json" \
-H "Authorization: Bearer $1" \
"https://api.digitalocean.com/v2/droplets?tag_name=jenkins-$2"
