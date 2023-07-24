# Compute

############################ Public IPs ############################

# Create Management Public IP
resource "azurerm_public_ip" "winvm_mgmt_pip" {
  name                = format("%s-winvm-mgmt-pip-%s", var.projectPrefix, random_id.buildSuffix.hex)
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"

  tags = {
    owner = var.resourceOwner
  }
}

# Create External Public IP
resource "azurerm_public_ip" "winvm_ext_pip" {
  name                = format("%s-winvm-ext-pip-%s", var.projectPrefix, random_id.buildSuffix.hex)
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"

  tags = {
    owner = var.resourceOwner
  }
}

############################ Network Interfaces ############################

# Create mgmt NIC
resource "azurerm_network_interface" "winvm_mgmt" {
  name                = format("%s-winvm-mgmt-nic-%s", var.projectPrefix, random_id.buildSuffix.hex)
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.mgmt.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.winvm_mgmt_pip.id
  }

  tags = {
    owner = var.resourceOwner
  }
}

# Create External NIC
resource "azurerm_network_interface" "winvm_ext" {
  name                = format("%s-winvm-ext-nic-%s", var.projectPrefix, random_id.buildSuffix.hex)
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.external.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.winvm_ext_pip.id
  }

  tags = {
    owner = var.resourceOwner
  }
}

############################ Virtual Machine ############################

# Create virtual machine
resource "azurerm_windows_virtual_machine" "winvm" {
  name                  = format("%s-winvm", var.projectPrefix)
  admin_username        = "azureuser"
  admin_password        = var.admin_password
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.winvm_mgmt.id, azurerm_network_interface.winvm_ext.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = format("%s-winvm-disk", var.projectPrefix)
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "win10-22h2-pro-g2"
    version   = "latest"
  }

  tags = {
    owner = var.resourceOwner
  }
}
