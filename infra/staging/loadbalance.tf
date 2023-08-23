## Load Balancer 생성 시작
# Load Balancer
resource "ncloud_lb" "lion-lb-tf" {
  name = "be-lb-staging"
  network_type = "PUBLIC"
  type = "NETWORK_PROXY"
  # 로드 밸런서는 구분지어진 하나의 서브넷을 받기 때문에 따로 설정해준다.
  subnet_no_list = [ ncloud_subnet.be-lb.id ]
}

# Target group
resource "ncloud_lb_target_group" "lion-lb-tf" {
  vpc_no   = ncloud_vpc.main.vpc_no
  protocol = "PROXY_TCP"
  target_type = "VSVR" # Target type 에서 VPC
  port        = 8000
  description = "for django be"
  health_check {
    protocol = "TCP" # PROXY_TCP 는 체크도 TCP 만
    http_method = "GET"
    port           = 8000
    url_path       = "/monitor/l7check"
    cycle          = 30
    up_threshold   = 2
    down_threshold = 2
  }
  algorithm_type = "RR"
}

# 어떤 프로토콜을 리스닝할건지 정의
resource "ncloud_lb_listener" "lion-lb-tf" {
  load_balancer_no = ncloud_lb.lion-lb-tf.load_balancer_no
  protocol = "TCP"
  port = 80
  target_group_no = ncloud_lb_target_group.lion-lb-tf.target_group_no
}

# 타겟 그룹 설정으로 대상 서버 인스터스를 정할 수 있다
# Target group attachment
resource "ncloud_lb_target_group_attachment" "lion-lb-tg-tf" {
  target_group_no = ncloud_lb_target_group.lion-lb-tf.target_group_no
  target_no_list = [ncloud_server.server.instance_no]
}
## Load Balancer 생성 끝
