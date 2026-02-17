variable "image_path" {
  type        = string
  description = "Pfad zum Ubuntu Cloud-Image"
  default     = sort(fileset("input", "*.img"))[0]
}

variable "image_checksum" {
  type        = string
  description = "SHA256-Checksumme des Cloud-Images"
  default     = "none"
}

variable "vm_name" {
  type        = string
  description = "Dateiname des fertigen Golden Images"
  default     = "golden-ubuntu.qcow2"
}

variable "cpus" {
  type        = number
  description = "Anzahl vCPUs fuer den Build"
  default     = 2
}

variable "memory" {
  type        = number
  description = "RAM in MB fuer den Build"
  default     = 1024
}

variable "disk_size" {
  type        = number
  description = "Disk-Groesse in MB"
  default     = 10000
}

variable "ssh_username" {
  type        = string
  description = "SSH-Benutzer fuer den Build"
  default     = "ubuntu"
}

variable "ssh_password" {
  type        = string
  description = "SSH-Passwort fuer den Build"
  default     = "ubuntu"
  sensitive   = true
}
