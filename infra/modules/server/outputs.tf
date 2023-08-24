
## main backend server IP
output "backend_public_ip" {
  value = ncloud_public_ip.be.public_ip
}

## db server IP
output "db_public_ip" {
  value = ncloud_public_ip.db.public_ip
}

output "be_server" {
  value = ncloud_server.be-server.id
}

output "subnet_be_loadbalancer" {
  value = ncloud_subnet.be-loadbalancer.id
}

# # Load balancer DNS check
# output "be-lb--dns" {
#     value = ncloud_lb.be-lb.domain
# }