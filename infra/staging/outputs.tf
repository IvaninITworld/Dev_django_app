
# ## main 서버 공인 IP 를 생성하면서 가져오기
# output "backend_public_ip" {
#   value = ncloud_public_ip.main.public_ip
# }

# ## db 서버 공인 IP 를 생성하면서 가져오기
# output "db_public_ip" {
#   value = ncloud_public_ip.db.public_ip
# }


# ## 서버 스펙 출력
# output "products" {
#   value = {
#     for product in data.ncloud_server_products.products.server_products:
#     product.id => product.product_name
#   }
# }

# ## 로드밸런서 도메인 주소값 출력
# output "ncloud-lb-domain" {
#   value = ncloud_lb.lion-lb-tf.domain
# }