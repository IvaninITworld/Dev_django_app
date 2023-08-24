# ## load balancer setup start
# # load balancer
# resource "ncloud_lb" "be-lb" {
#   name = "tf-lb-prod"
#   network_type = "PUBLIC"
#   type = "NETWORK_PROXY"
#   throughput_type = "SMALL"
#   subnet_no_list = [ ncloud_subnet.be-loadbalancer.id ]
# }
# # target group
# resource "ncloud_lb_target_group" "be-lb" {
#     name = "be-tg-prod"
#     vpc_no   = ncloud_vpc.main.vpc_no
#     protocol = "PROXY_TCP"
#     target_type = "VSVR"
#     port        = 8000
#     description = "for django prod backend"
#     health_check {
#         protocol = "TCP"
#         http_method = "GET"
#         port           = 8000
#         url_path       = "/monitor/l7check"
#         cycle          = 30
#         up_threshold   = 2
#         down_threshold = 2
#     }
#     algorithm_type = "RR"
# }
# # listening protocal
# resource "ncloud_lb_listener" "be-lb-prod" {
#     load_balancer_no = ncloud_lb.be-lb-prod.id
#     protocol = "TCP"
#     port = 80
#     target_group_no = ncloud_lb_target_group.be-lb-prod.id
# }
# # select applying instance
# resource "ncloud_lb_target_group_attachment" "be-lb-prod" {
#   target_group_no = ncloud_lb_target_group.be-lb-prod.id
#   target_no_list = [ncloud_server.be-prod-server.id]
# }

# ## load balancer setup end