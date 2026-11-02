module "naming" {
  source       = "git::https://github.com/uncle-sola/shared-tf.git?ref=ae76f896e2e9aea5127659d526a7f72576cd2e0b" # v1.0.5
  environment  = var.environment
  project_code = "ALP"
  region       = var.location
}
