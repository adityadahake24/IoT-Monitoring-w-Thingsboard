resource "aws_lb" "thingsboard_nlb" {
  name               = "thingsboard-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  enable_deletion_protection = false
  tags = {
    Name = "thingsboard-nlb"
  }
}

resource "aws_lb_target_group" "webapp_tg" {
  name        = "webapp-tg"
  port        = 8080
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.ecs_vpc.id
}

resource "aws_lb_target_group" "mqtt_tg" {
  name        = "mqtt-tg"
  port        = 1883
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.ecs_vpc.id
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.thingsboard_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg.arn
  }
}

resource "aws_lb_listener" "mqtt_listener" {
  load_balancer_arn = aws_lb.thingsboard_nlb.arn
  port              = 1883
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mqtt_tg.arn
  }
}
