variable "my_vpc" {
  description = "VPC for testing environment"
  type        = string
  default     = "10.0.0.0/16"
}


variable "ami_id" {
  description = "ami id"
  type        = string
  default     = "ami-0b5eea76982371e91"
}

variable "instance_type" {
  description = "Instance type to create an instance"
  type        = string
  default     = "t2.micro"
}

variable "ssh_private_key" {
  description = "pem file of Keypair we used to login to EC2 instances"
  type        = string
  default     = "./mykeypair.pem"
}
