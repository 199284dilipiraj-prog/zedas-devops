variable "customer_name" {
  description = "Name of the demo customer environment"
  type        = string
}

variable "azure_region" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "norwayeast"
}

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key file"
  type        = string
  default     = "~/.ssh/zedas_id_rsa.pub"
}

variable "allowed_ssh_ip" {
  description = "Your IP address allowed for SSH access"
  type        = string
}
