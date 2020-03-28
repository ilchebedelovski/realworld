resource "digitalocean_spaces_bucket" "bucket" {
  name   = var.do_bucket_name
  region = var.do_bucket_region
}
