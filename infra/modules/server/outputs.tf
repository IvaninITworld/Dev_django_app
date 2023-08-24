
## main backend server IP
output "backend_public_ip" {
  value = ncloud_public_ip.be.public_ip
}

## db server IP
output "db_public_ip" {
  value = ncloud_public_ip.db.public_ip
}

# # Load balancer DNS check
# output "be-lb--dns" {
#     value = ncloud_lb.be-lb.domain
# }