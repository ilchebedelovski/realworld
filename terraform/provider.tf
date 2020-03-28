provider "digitalocean" {
  token = var.do_token
  spaces_access_id  = var.do_access_id
  spaces_secret_key = var.do_secret_key
}
