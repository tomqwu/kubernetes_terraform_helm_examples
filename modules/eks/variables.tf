variable "env_name" {}

variable "app_name" {}

variable "ingress_sg_cidrs" {
  type = "list"
}

variable "vpc_name" {}

variable "worker_instance_type" {}

variable "worker_asg_desired_capacity" {
  default = 2
}

variable "worker_asg_max_size" {
  default = 10
}

variable "worker_asg_min_size" {
  default = 1
}
