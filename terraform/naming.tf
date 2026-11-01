module "naming" {
  source       = "git::https://github.com/uncle-sola/shared-tf.git?ref=323812276232f634ce1e5ba6a9bc03eea4f8de8d" # v1.0.4
  environment  = var.environment
  project_code = "ALP"
  region       = var.location
}
