# NOTE: Step 1 is scaffolding only.
# In Step 2/3 we will implement modules/vpc and modules/eks and wire them here.

module "vpc" {
  source = "../../modules/vpc"

  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  enable_nat_gateway = var.enable_nat_gateway
}

module "eks" {
  source = "../../modules/eks"

  project_name = var.project_name
  environment  = var.environment

  vpc_id          = module.vpc.vpc_id
  public_subnets  = module.vpc.public_subnet_ids
  # public_subnets  = [module.vpc.public_subnet_ids[0]]
  private_subnets = module.vpc.private_subnet_ids

  cluster_version     = var.cluster_version
  node_instance_types = var.node_instance_types
  node_desired_size   = var.node_desired_size
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_capacity_type  = var.node_capacity_type
  node_subnet_type    = var.node_subnet_type

  cluster_public_access_cidrs = var.cluster_public_access_cidrs
}

