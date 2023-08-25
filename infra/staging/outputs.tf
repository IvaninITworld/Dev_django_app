## main 서버 공인 IP 를 생성하면서 가져오기
output "lb_dns" {
  value = module.loadbalancer.lb-dns
}

output "db_public_ip" {
  value = ncloud_public_ip.db.instance_no
}

output "be_public_ip" {
  value = ncloud_public_ip.be.instance_no
}