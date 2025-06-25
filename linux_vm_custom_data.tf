resource "azurerm_resource_group" "cd_rg" {
  name     = "cdrg"
  location = "West Europe"
}

resource "azurerm_virtual_network" "cd_vnet" {
  name                = "cdvnet"
  address_space       = ["10.0.0.0/16"] #65536-5 = 65531
  location            = azurerm_resource_group.cd_rg.location
  resource_group_name = azurerm_resource_group.cd_rg.name
}

resource "azurerm_subnet" "cd_subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.cd_rg.name
  virtual_network_name = azurerm_virtual_network.cd_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# resource "azurerm_subnet" "cd_subnet1" {
#   name                 = "internal"
#   resource_group_name  = azurerm_resource_group.cd_rg.name
#   virtual_network_name = azurerm_virtual_network.cd_vnet.name
#   address_prefixes     = ["10.0.2.0/24"]
# }



resource "azurerm_network_interface" "cd_nic" {
  name                = "customd-nic"
  location            = azurerm_resource_group.cd_rg.location
  resource_group_name = azurerm_resource_group.cd_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.cd_subnet.id
    public_ip_address_id          = azurerm_public_ip.cd_pip.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "cd_pip" {
  name                = "cdpip"
  resource_group_name = azurerm_resource_group.cd_rg.name
  location            = azurerm_resource_group.cd_rg.location
  allocation_method   = "Dynamic"
  sku = "Basic"

}

resource "azurerm_linux_virtual_machine" "cd_linux" {
  name                            = "cdlinuxvm"
  resource_group_name             = azurerm_resource_group.cd_rg.name
  location                        = azurerm_resource_group.cd_rg.location
  size                            = "Standard_F2"
  admin_username                  = "adminuser"
  admin_password                  = "Welcome@1234"
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.cd_nic.id, ]
  


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
