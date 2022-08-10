variable "region" {
  type = string
}

variable "subnet" {
  type = list(any)
}

variable "k8s_version" {
  type = string
}
variable "nodegroup_name" {
  type = string
}

variable "ami" {
  type = string
}

variable "instance_types" {
  type = list(any)
}

variable "capacity_type" {
  type = string
}

variable "node_role_name" {
  type = string
}

variable "cluster_role_name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "cluster_name" {
  type = string
}
