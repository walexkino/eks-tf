region = "us-east-1"

subnet = ["subnet-005454d33be2c7a2a", "subnet-09e18de88b2c9a5af", "subnet-0eb2621ee04a85ea3"]

k8s_version = 1.22

nodegroup_name = "node-1"

ami = "AL2_x86_64"

instance_types = ["t3.small"]

capacity_type = "ON_DEMAND"

node_role_name = "AmazonEKSNodeRole"

cluster_role_name = "AmazonEKSClusterRole"

vpc_id = "vpc-08e161aa57aa06673"

cluster_name = "project"

