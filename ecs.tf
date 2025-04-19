resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ThingsBoard-Cluster"
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "ThingsBoard-Capacity-Provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn
    
    managed_scaling {
      status = "ENABLED"
      target_capacity = 3
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 10
    }
  }
}