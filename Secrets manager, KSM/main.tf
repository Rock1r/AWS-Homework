module "secrets" {
  source = "./modules/secrets"
}

module "iam" {
  source = "./modules/iam"
  secret_key_arn = module.secrets.secret_key_arn
  kms_key_arn    = module.secrets.kms_key_arn
}

module "key_pairs" {
  source = "./modules/key_pairs"
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.network.vpc_id
}

module "network" {
  source = "./modules/network"
}

module "instances" {
  source = "./modules/instances"
  public_subnet_id           = module.network.public_subnet_id
  key_name            = module.key_pairs.key_name
  bastion_security_group_id   = module.security_groups.bastion_sg_id
  bastion_iam_profile_name     = module.iam.bastion_iam_profile_name
}