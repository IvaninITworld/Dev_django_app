## main 서버 공인 IP 를 생성하면서 가져오기
output "backend_public_ip" {
  value = module.servers.backend_public_ip
}

## db 서버 공인 IP 를 생성하면서 가져오기
output "db_public_ip" {
  value = module.servers.db_public_ip
}

output "loadbalance_dns" {
  value = module.loadbalancer.lb-dns
}

