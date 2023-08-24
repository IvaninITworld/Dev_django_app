
## main backend server IP
output "backend_public_ip" {
  value = ncloud_public_ip.we-prod.public_ip
}

## db server IP
output "db_public_ip" {
  value = ncloud_public_ip.db-prod.public_ip
}

# # Load balancer DNS check
# output "be-lb-prod-dns" {
#     value = ncloud_lb.be-lb-prod.domain
# }