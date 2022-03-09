provider "aws"{ region = "eu-central-1"}


resource "aws_vpc" "ITC-Test-VPC" {
cidr_block  ="10.10.0.0/16"
enable_dns_hostnames = "true"
tags = {
 Name = "TF-ITC-Test-VPC"
 Environment = "Test"}
} 

/*
resource "aws_subnet" "AZ-1-Public-SN" {
vpc_id     = aws_vpc.ITC-Test-VPC.id  
cidr_block  = "10.10.0.0/24"
availability_zone   = "eu-central-1a"
map_public_ip_on_launch = "true"
tags = {
 Name = "TF-AZ-1-Public-SN"
 Environment = "Test"}
}                  
resource "aws_subnet" "AZ-2-Public-SN" {
vpc_id     = aws_vpc.ITC-Test-VPC.id  
cidr_block  = "10.10.1.0/24"
availability_zone   = "eu-central-1b"
map_public_ip_on_launch = "true"
tags = {
 Name = "TF-AZ-2-Public-SN"
 Environment = "Test"}
}                  


resource "aws_subnet" "AZ-1-Private-SN" {
vpc_id     = aws_vpc.ITC-Test-VPC.id  
cidr_block  = "10.10.3.0/24"
availability_zone   = "eu-central-1a"
  tags = {
    Name = "TF-AZ-1-Private-SN"
    Environment = "Test"}
} 

resource "aws_subnet" "AZ-2-Private-SN" {
  vpc_id     = aws_vpc.ITC-Test-VPC.id  
  cidr_block  = "10.10.4.0/24"
  availability_zone   = "eu-central-1b"

  tags = {
    Name = "TF-AZ-2-Private-SN"
    Environment = "Test"}
} 


resource "aws_eip" "Bastion-EIP" {
 vpc   =  true
 tags = {
   Name = "TF-Bastion-EIP"
   Environment = "Test"}
} 
resource "aws_eip" "NAT1-EIP" {
 vpc   =  true
 tags = {
   Name = "TF-NAT1-EIP"
   Environment = "Test"}
} 


resource "aws_internet_gateway" "ITC-Test-Working-IGW" {
 vpc_id     = aws_vpc.ITC-Test-VPC.id  

tags = {
 Name = "TF-ITC-Working-IGW"
 Environment = "Test"}
} 

resource "aws_nat_gateway" "Public-SN1-NAT" {
  allocation_id = aws_eip.NAT1-EIP.id
  subnet_id     = aws_subnet.AZ-1-Public-SN.id
  tags = {
    Name = "TF-ITC-Public-SN1-NAT"
  }
}


resource "aws_route_table" "ITC-Public-SN1-RT" {
 vpc_id     = aws_vpc.ITC-Test-VPC.id  
 route  {
   cidr_block = "0.0.0.0/0" 
   gateway_id  = aws_internet_gateway.ITC-Test-Working-IGW.id
 }
 tags = {
 Name = "TF-ITC-Public-SN1-RT"
 Environment = "Test"}
} 

resource "aws_route_table" "ITC-Public-SN2-RT" {
 vpc_id     = aws_vpc.ITC-Test-VPC.id  
 route  {
   cidr_block = "0.0.0.0/0" 
   gateway_id  = aws_internet_gateway.ITC-Test-Working-IGW.id
 }
tags = {
 Name = "TF-ITC-Public-SN2-RT"
 Environment = "Test"}
} 

resource "aws_route_table" "ITC-Private-SN1-RT" {
  vpc_id     = aws_vpc.ITC-Test-VPC.id  
  route  {
   cidr_block = "0.0.0.0/0" 
   nat_gateway_id = aws_nat_gateway.Public-SN1-NAT.id
   } 
  tags = {
  Name = "TF-ITC-Private-SN1-RT"
  Environment = "Test"}
} 

resource "aws_route_table" "ITC-Private-SN2-RT" {
  vpc_id     = aws_vpc.ITC-Test-VPC.id  
   route  {
   cidr_block = "0.0.0.0/0" 
   nat_gateway_id = aws_nat_gateway.Public-SN1-NAT.id
   }
  tags = {
  Name = "TF-ITC-Private-SN2-RT"
  Environment = "Test"}
} 


resource "aws_route_table_association" "PublicSubnet01RouteTableAssociation" {
  subnet_id      = aws_subnet.AZ-1-Public-SN.id  
  route_table_id    = aws_route_table.ITC-Public-SN1-RT.id  
} 
resource "aws_route_table_association" "PublicSubnet02RouteTableAssociation" {
  subnet_id      = aws_subnet.AZ-2-Public-SN.id  
  route_table_id    = aws_route_table.ITC-Public-SN2-RT.id  
} 

resource "aws_route_table_association" "PrivateSubnet01RouteTableAssociation" {
  subnet_id      = aws_subnet.AZ-1-Private-SN.id  
  route_table_id = aws_route_table.ITC-Private-SN1-RT.id  
} 
resource "aws_route_table_association" "PrivateSubnet02RouteTableAssociation" {
  subnet_id      = aws_subnet.AZ-2-Private-SN.id  
  route_table_id = aws_route_table.ITC-Private-SN2-RT.id  
} 
resource "aws_security_group" "Bastion-SG" {
  vpc_id     = aws_vpc.ITC-Test-VPC.id  
  tags = {
  Name = "TF-Bastion-SG"
  Environment = "Test"}
} 


resource "aws_security_group_rule" "Bastion-SSH-SG-Role" {
  description  =  "ingress_bastion_SSH"
  type        = "ingress"
  security_group_id   =  aws_security_group.Bastion-SG.id  
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks  = ["0.0.0.0/0"]
} 

resource "aws_security_group_rule" "egress_bastion" {
 description  =  "egress_bastion"
  type = "egress"
  security_group_id   =  aws_security_group.Bastion-SG.id  
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks  = ["0.0.0.0/0"]
} 

resource "aws_instance" "ITC-Test-Bastion" {
 ami   =  data.aws_ami.Amazon-Linux-2.id  
  instance_type  = "t3.micro"
  key_name  = "EnvOps-AWS-KeyPair"
  vpc_security_group_ids   = [aws_security_group.Bastion-SG.id]  
  subnet_id   = aws_subnet.AZ-1-Public-SN.id  
  associate_public_ip_address  = true 
  tags = {
  Name = "TF-ITC-Test-Bastion"
  Environment = "Test"}
} 

data "aws_ami" "Amazon-Linux-2" {
 most_recent = true
 owners           = ["amazon"]
filter  {
    name = "name"
  values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
} 
resource "aws_eip_association" "Bastion_eip_assoc" {
  instance_id   = aws_instance.ITC-Test-Bastion.id
  allocation_id = aws_eip.Bastion-EIP.id
}

resource "aws_iam_role" "TF-EKS-Cluster-Role" {
    name  =  "TF-EKS-Cluster-Role"
    assume_role_policy    =   data.aws_iam_policy_document.EKS_cluster_assume_role_policy.json
    description  =  "a Role to  enable the EKS Service  to manage resources withing the cluster"
    force_detach_policies = true
} 
resource "aws_iam_role" "TF-EKS-Workers-Role" {
    name  =  "ITC_EKS_Worker_NG_Role"

    assume_role_policy = jsonencode({
      Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }]
      Version = "2012-10-17"
    })
}

### 3 Roles for the EKS Work Group
resource "aws_iam_role_policy_attachment" "ITC-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.TF-EKS-Workers-Role.name
}

resource "aws_iam_role_policy_attachment" "ITC-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.TF-EKS-Workers-Role.name
}

resource "aws_iam_role_policy_attachment" "ITC-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.TF-EKS-Workers-Role.name
}

### - End 3 roles for worker group

## Role for EKS cluster
resource "aws_iam_role_policy_attachment" "TF-AmazonEKSClusterPolicy-Attch" {
    role =   aws_iam_role.TF-EKS-Cluster-Role.name
    policy_arn =  "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
} 

data "aws_iam_policy_document" "EKS_cluster_assume_role_policy" {
  
  statement {
    sid     = "EKSClusterAssumeRole"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

resource "aws_eks_cluster" "TF-ITC-Test-EKS-Cluster" {
 name  =  "ITC-Test-EKS-Cluster"
    role_arn  =   aws_iam_role.TF-EKS-Cluster-Role.arn
    vpc_config  {
    subnet_ids = [aws_subnet.AZ-1-Public-SN.id, aws_subnet.AZ-2-Public-SN.id] 
   }                       
    tags = {
      Name = "ITC-Test-EKS-Cluster"
      Environment = "Test"}
} 
## Create Node Group 
resource "aws_eks_node_group" "EKS_Test_NG" {
  cluster_name    = aws_eks_cluster.TF-ITC-Test-EKS-Cluster.name
  node_group_name = "EKS_Test_NG"
  node_role_arn   = aws_iam_role.TF-EKS-Workers-Role.arn
  subnet_ids      = [aws_subnet.AZ-1-Private-SN.id, aws_subnet.AZ-2-Private-SN.id] 
  disk_size       = 40
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  update_config {
    max_unavailable = 1
  }
  
  depends_on = [
    aws_iam_role_policy_attachment.ITC-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.ITC-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.ITC-AmazonEC2ContainerRegistryReadOnly,
  ]
}
*/
