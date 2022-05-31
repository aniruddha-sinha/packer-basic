source "googlecompute" "basic-example" {
  project_id          = var.project_id
  source_image_family = var.source_image_family
  ssh_username        = "vaulte"
  disk_size           = "50"
  disk_type           = "pd-standard"
  zone                = var.zone
  network             = "odin-thirteen-net-2-prim-vpc"
  subnetwork          = "odin-thirteen-us-central1-net-2-subnet"
  omit_external_ip    = true
  use_internal_ip     = true
  preemptible         = true
  #the flag below will not create your image so you wont have to delete it; 
  #however compute charges may apply
  skip_create_image       = false
  use_iap                 = true
  image_labels            = var.image_labels
  temporary_key_pair_type = "ed25519"
  startup_script_file     = "./startup-script/vault-oss.sh"
}

build {
  sources = ["sources.googlecompute.basic-example"]
}

