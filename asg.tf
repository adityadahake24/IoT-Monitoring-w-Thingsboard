resource "aws_autoscaling_group" "ecs_asg" {
  vpc_zone_identifier = [aws_subnet.public_subnet_1.id , aws_subnet.public_subnet_2.id] 
  desired_capacity   = 1
  max_size           = 3
  min_size           = 1
  
  launch_template {
    id      = aws_launch_template.thinsboard_installation.id
    version = "$Latest"
  }
  tag {
    key = "AmazonECSManaged"
    value = "true"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "ecs_nlb_attachment_http" {
  autoscaling_group_name = aws_autoscaling_group.ecs_asg.name
  lb_target_group_arn    = aws_lb_target_group.webapp_tg.arn
}

resource "aws_autoscaling_attachment" "ecs_nlb_attachment_mqtt" {
  autoscaling_group_name = aws_autoscaling_group.ecs_asg.name
  lb_target_group_arn    = aws_lb_target_group.mqtt_tg.arn
}
