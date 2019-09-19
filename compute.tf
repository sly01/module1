resource "aws_launch_configuration" "asg_launch_conf" {
  image_id        = "${data.aws_ami.ubuntu.id}"
  instance_type   = "${var.instance_size}"
  security_groups = ["${aws_security_group.allow_web.id}"]
  user_data       = <<-EOF
  #!/bin/bash
  echo "<h1><font color="red">Hello from Atos Bydgoszcz ${var.region} - ${var.env}</font></h1>" > index.html
  curl http://169.254.169.254/latest/meta-data/instance-id >> index.html
  sudo nohup busybox httpd -f -p "${var.web_port}" &
  EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg_atos" {
  launch_configuration = "${aws_launch_configuration.asg_launch_conf.id}"
  availability_zones = "${data.aws_availability_zones.all.names}"
  max_size = "${var.max_size}"
  min_size = "${var.min_size}"

  load_balancers = ["${aws_elb.elb.name}"]
  health_check_type = "ELB"

  tag {
    key = "Name"
    value = "atos-asg-example"
    propagate_at_launch = true
  }
}
