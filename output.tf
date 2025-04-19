output "LoadbalancerAddress" {
  value = aws_lb.thingsboard_nlb.dns_name
}