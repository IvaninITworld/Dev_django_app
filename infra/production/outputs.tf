
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

