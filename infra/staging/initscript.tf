# ## init script 설정 시작
# resource "ncloud_init_script" "be" {
#   name    = "set-be-tf"
#   content = templatefile("${path.module}/be_init_script.tftpl", {
#     password = var.password
#     db = var.db
#     db_user = var.db_user
#     db_password = var.db_password
#     db_port = var.db_port
#     db_host = ncloud_public_ip.db.public_ip
#     NCP_ACCESS_KEY = var.NCP_ACCESS_KEY
#     NCP_SECRET_KEY = var.NCP_SECRET_KEY
#     NCP_CONTAINER_REGISTRY = var.NCP_CONTAINER_REGISTRY
#     IMAGE_TAG = var.IMAGE_TAG
#     DJANGO_SECRET_KEY = var.DJANGO_SECRET_KEY
#     DJANGO_SETTINGS_MODULE = var.DJANGO_SETTINGS_MODULE
#   })
# } # Shell Script 로 가져다 쓰기: .tftpl

# resource "ncloud_init_script" "db" {
#   name    = "set-db-tf"
#   content = templatefile("${path.module}/db_init_script.tftpl", {
#     password = var.password
#     db = var.db
#     db_user = var.db_user
#     db_password = var.db_password
#     db_port = var.db_port
#   })
# } # Shell Script 로 가져다 쓰기: .tftpl
# ## init script 설정 끝
