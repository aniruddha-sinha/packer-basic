variable "project_id" {
  type        = string
  description = "The name of the project ID"
}

variable "image_labels" {
  type        = map(string)
  description = "gcp based labels"
}

variable "zone" {
  type = string
}

variable "disk_type" {
  type    = string
  default = "pd-standard"
}

variable "disk_size" {
  type    = number
  default = 50
}