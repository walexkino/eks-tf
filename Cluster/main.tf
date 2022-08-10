
resource "aws_eks_cluster" "project" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn
  version = var.k8s_version

  vpc_config {
    subnet_ids = var.subnet
    endpoint_private_access = true
    security_group_ids = [aws_security_group.node-port.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster-policy,
    aws_iam_role_policy_attachment.vpc-controller,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.project.endpoint
}

resource "aws_eks_addon" "cni" {
  cluster_name = aws_eks_cluster.project.name
  addon_name   = "vpc-cni"
  addon_version = "v1.11.2-eksbuild.1"
}

resource "aws_eks_addon" "proxy" {
  cluster_name = aws_eks_cluster.project.name
  addon_name   = "kube-proxy"
  addon_version = "v1.22.11-eksbuild.2"
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.project.name
  addon_name   = "coredns"
  addon_version = "v1.8.7-eksbuild.1"
}

resource "aws_iam_role" "cluster_role" {
  name = var.cluster_role_name

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster_role.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "vpc-controller" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster_role.name
}

resource "aws_eks_node_group" "project" {
  cluster_name    = aws_eks_cluster.project.name
  node_group_name = var.nodegroup_name
  node_role_arn   = aws_iam_role.eks_noderole.arn
  subnet_ids      = var.subnet
  ami_type = var.ami
  instance_types = var.instance_types
  capacity_type = var.capacity_type

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.registry,
    aws_iam_role_policy_attachment.cni-policy,
    aws_iam_role_policy_attachment.worker-node,
  ]
}

resource "aws_iam_role" "eks_noderole" {
  name = var.node_role_name
    assume_role_policy = <<POLICY
    {
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "eks.amazonaws.com",
            "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
    }
    POLICY
}

resource "aws_iam_role_policy_attachment" "registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_noderole.name
}

resource "aws_iam_role_policy_attachment" "worker-node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_noderole.name
}

resource "aws_iam_role_policy_attachment" "cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_noderole.name
}

resource "aws_security_group" "node-port" {
  name        = "allow_nodeport"
  description = "Allow TLS inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    description      = "Node Port from Internet"
    from_port        = 30000
    to_port          = 30000
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}
