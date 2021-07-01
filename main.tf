terraform {
  required_version = "~> 0.13.0"
  required_providers {
    azurerm = "~> 2.25.0"
  }
}

provider "azurerm" {
  features {
}
          subscription_id = "0825a2e6-549b-4c01-948e-b9f311d3c5cc"
          client_id = "d84662ed-59c0-4373-bfaa-46fb139690cd"
          client_secret = "FrV_Hfq6zMZ.EQsRQKb0XyT8othh9qXbV."
          tenant_id = "6945d4e9-9ba6-4340-9702-da340b1ee87e"
}

module "linux_vm" {
  source = "./modules/linux-vm"

  rgName             = "ansibledev-${var.technician_initials}"
  rgLocation         = "australiaeast"
  vnetName           = "ansibledev-${var.technician_initials}"
  vnetAddressSpace   = ["10.0.0.0/24"]
  vnetSubnetName     = "default"
  vnetSubnetAddress  = "10.0.0.0/24"
  nsgName            = "ansibledev-${var.technician_initials}"
  vmNICPrivateIP     = "10.0.0.5"
  vmPublicIPDNS      = "ansibledev-${var.technician_initials}"
  vmName             = "ansibledev-${var.technician_initials}"
  vmSize             = "Standard_B2s"
  vmAdminName        = "ansibleadmin" #If this is changed ensure you update "./scripts/ubuntu-setup-ansible.sh" with the new username
  vmShutdownTime     = "1900"
  vmShutdownTimeZone = "AUS Eastern Standard Time"
  vmSrcImageReference = {
    "publisher" = "Canonical"
    "offer"     = "UbuntuServer"
    "sku"       = "18.04-LTS"
    "version"   = "latest"
  }
  nsgRule1 = {
    "name"                       = "SSH_allow"
    "description"                = "Allow inbound SSH from single Public IP to Ansible Host"
    "priority"                   = 100
    "direction"                  = "Inbound"
    "access"                     = "Allow"
    "protocol"                   = "Tcp"
    "source_port_range"          = "*"
    "destination_port_range"     = "22"
    "source_address_prefix"      = "0.0.0.0" #Update with your own public IP address https://www.whatismyip.com/
    "destination_address_prefix" = "10.0.0.5"
  }
}
