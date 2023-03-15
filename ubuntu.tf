# Create public IPs
resource "azurerm_public_ip" "public_ip" {
  name                = "u1-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"

  tags = {
    environment = "azure-demo"
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nsg" {
  name                = "u1-ngs"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

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

  tags = {
    environment = "azure-demo"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
    depends_on = [
      azurerm_subnet.linux-subnet
    ]
  name                = "u1-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration"
    subnet_id                     = azurerm_subnet.linux-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = {
    environment = "azure-demo"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "storage" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "azure-demo"
  }
}

# Create (and display) an SSH key
resource "tls_private_key" "example_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
  #   keepers = {
  #   # Generate a new ID only when a new resource group is defined
  #   resource_group = azurerm_resource_group.rg.name
  # }
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                  = "ubuntu1"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_DS1_v2"

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

  computer_name                   = "ubuntu1"
  admin_username                  = "azureuser"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "azureuser"
    public_key = tls_private_key.example_ssh.public_key_openssh
  }

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.storage.primary_blob_endpoint
  }

  tags = {
    environment = "azure-demo"
  }
}

resource "azurerm_route_table" "linux-rt" {
  name                          = "linux-rt-tf"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "to-internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = "10.42.4.4"
  }

  tags = {
    environment = "Production"
  }
}

resource "azurerm_subnet_route_table_association" "linux-rt-to-subnet" {
  subnet_id      = azurerm_subnet.linux-subnet.id
  route_table_id = azurerm_route_table.linux-rt.id
}

output "ssh_ip" {
    
    value = azurerm_linux_virtual_machine.linuxvm.public_ip_address
}

output "ssh_key" {
    value = tls_private_key.example_ssh.private_key_pem
    sensitive = true
}

