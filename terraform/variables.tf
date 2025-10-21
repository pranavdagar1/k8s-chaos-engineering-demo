variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "eu-north-1"
}
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}
