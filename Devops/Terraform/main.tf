resource "random_pet" "botitname" {
  prefix = var.resource_group_name_prefix
}

resource "azurerm_resource_group" "botit" {
  location = var.resource_group_location
  name     = random_pet.botitname.id
}

# Create virtual network
resource "azurerm_virtual_network" "Botit_network" {
  name                = "BotitNetwork"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.botit.location
  resource_group_name = azurerm_resource_group.botit.name
}

# Create subnet
resource "azurerm_subnet" "Botit_subnet" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.botit.name
  virtual_network_name = azurerm_virtual_network.Botit_network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "Botit_public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.botit.location
  resource_group_name = azurerm_resource_group.botit.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "Botit_nsg" {
  name                = "myNetworkSecurityGroup"
  location            = azurerm_resource_group.botit.location
  resource_group_name = azurerm_resource_group.botit.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "Botit_nic" {
  name                = "myNIC"
  location            = azurerm_resource_group.botit.location
  resource_group_name = azurerm_resource_group.botit.name

  ip_configuration {
    name                          = "my_nic_configuration"
    subnet_id                     = azurerm_subnet.Botit_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.Botit_public_ip.id
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
  network_interface_id      = azurerm_network_interface.Botit_nic.id
  network_security_group_id = azurerm_network_security_group.Botit_nsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.botit.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "my_storage_account" {
  name                     = "botitstorage"
  location                 = azurerm_resource_group.botit.location
  resource_group_name      = azurerm_resource_group.botit.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create (and display) an SSH key
resource "tls_private_key" "Botit_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "Botit_vm" {
  name                             = "myVM"
  location                         = azurerm_resource_group.botit.location
  resource_group_name              = azurerm_resource_group.botit.name
  network_interface_ids            = [azurerm_network_interface.Botit_nic.id]
  size                             = "Standard_B2ms"


  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }


  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  computer_name                   = "myvm"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.Botit_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.my_storage_account.primary_blob_endpoint
  }
}
