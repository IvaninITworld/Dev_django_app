## Seversepc 데이터 삽입 시작
data "ncloud_server_products" "products" {
  server_image_product_code = "SW.VSVR.OS.LNX64.UBNTU.SVR2004.B050"

  filter {
    name   = "product_code"
    values = ["SSD"]
    regex  = true
  }

  filter {
    name   = "cpu_count"
    values = ["2"]
  }

  filter {
    name   = "memory_size"
    values = ["4GB"]
  }

  filter {
    name   = "base_block_storage_size"
    values = ["50GB"]
  }

  filter {
    name   = "product_type"
    values = ["HICPU"]
  }

  output_file = "product.json"
}
## 서버스펙 데이터 삽입 끝