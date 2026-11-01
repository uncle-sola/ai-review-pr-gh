module "naming" {
  source       = "git::https://github.com/uncle-sola/shared-tf.git?ref=v1.0.4"
  environment  = var.environment
  project_code = "ALP"
  region       = var.location
}
