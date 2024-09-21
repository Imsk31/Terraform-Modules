terraform {
  backend "local" {
    path = var.backend_path
  }
}