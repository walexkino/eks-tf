terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.24.0"
    }
  }
  #   backend "s3" {
  #     bucket = "mybucket"
  #     key    = "path/to/my/key"
  #     region = "us-east-1"
  #   }

}

provider "aws" {
  region  = var.region
#   shared_credentials_files = [ "/Users/cmadu/.aws/credentials" ]
#   profile = "terraform"
}


module "cluster" {
  source            = "./Cluster"
  cluster_role_name = var.cluster_role_name
  subnet            = var.subnet
  cluster_name      = var.cluster_name
  k8s_version       = var.k8s_version
  nodegroup_name    = var.nodegroup_name
  node_role_name    = var.node_role_name
  ami               = var.ami
  vpc_id            = var.vpc_id
  instance_types    = var.instance_types
  capacity_type     = var.capacity_type
}
