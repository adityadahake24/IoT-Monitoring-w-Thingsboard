resource "aws_launch_template" "thinsboard_installation" {
  name = "thingsboard-installation"
  image_id = "ami-02bd60530cb7649eb"
  instance_type = "t2.xlarge"
  key_name = "Optimus"
  
  vpc_security_group_ids = [aws_security_group.ecs_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance_profile.name
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp3"
    }
  }
  user_data = filebase64("${path.module}/install_thingsboard.sh")  
}