source "googlecompute" "basic-example" {
  project_id          = var.project_id
  source_image_family = "rocky-linux-8"
  ssh_username        = "vaulte"
  disk_size           = "50"
  disk_type           = "pd-standard"
  zone                = var.zone
  #the flag below will not create your image so you wont have to delete it; 
  #however compute charges may apply
  skip_create_image = true
  image_labels      = var.image_labels
}

build {
  sources = ["sources.googlecompute.basic-example"]
}

