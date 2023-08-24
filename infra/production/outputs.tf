## main 서버 공인 IP 를 생성하면서 가져오기
output "backend_public_ip" {
  value = module.servers.backend_public_ip
}

## db 서버 공인 IP 를 생성하면서 가져오기
output "db_public_ip" {
  value = module.servers.db_public_ip
}

# ## main backend server IP
# output "backend_public_ip" {
#   value = ncloud_public_ip.we-prod.public_ip
# }

# ## db server IP
# output "db_public_ip" {
#   value = ncloud_public_ip.db-prod.public_ip
# }

# ## server specs product
# output "products" {
#   value = {
#     for product in data.ncloud_server_products.products.server_products:
#     product.id => product.product_name
#   }
# }

# # Load balancer DNS check
# output "be-lb-prod-dns" {
#     value = ncloud_lb.be-lb-prod.domain
# }

