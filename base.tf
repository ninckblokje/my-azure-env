/*  
  Copyright (c) 2022, ninckblokje
  All rights reserved.
  
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
  
  * Redistributions of source code must retain the above copyright notice, this
    list of conditions and the following disclaimer.
  
  * Redistributions in binary form must reproduce the above copyright notice,
    this list of conditions and the following disclaimer in the documentation
    and/or other materials provided with the distribution.
  
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

resource "azurerm_resource_group" "speeltuin-jnb" {
  name     = "speeltuin-jnb"
  location = "westeurope"
}

resource "azurerm_ssh_public_key" "jnb-public-key" {
  name                = "jnb-public-key"
  location            = azurerm_resource_group.speeltuin-jnb.location
  resource_group_name = azurerm_resource_group.speeltuin-jnb.name
  public_key          = var.public_key
}

resource "azurerm_network_security_group" "jnb-default-nsg" {
  name                = "jnb-default-nsg"
  location            = azurerm_resource_group.speeltuin-jnb.location
  resource_group_name = azurerm_resource_group.speeltuin-jnb.name
}

resource "azurerm_network_security_rule" "allow-home-rule" {
  name                                       = "allow-home-rule"
  resource_group_name                        = azurerm_resource_group.speeltuin-jnb.name
  network_security_group_name                = azurerm_network_security_group.jnb-default-nsg.name
  access                                     = "Allow"
  description                                = ""
  destination_address_prefix                 = "*"
  destination_port_range                     = "*"
  direction                                  = "Inbound"
  priority                                   = 100
  protocol                                   = "*"
  source_address_prefix                      = var.home_ip
  source_port_range                          = "*"
}

resource "azurerm_network_security_group" "jnb-apim-nsg" {
  name                = "jnb-apim-nsg"
  location            = azurerm_resource_group.speeltuin-jnb.location
  resource_group_name = azurerm_resource_group.speeltuin-jnb.name
}

resource "azurerm_network_security_rule" "apim-http-rule" {
  name                                       = "apim-http-rule"
  resource_group_name                        = azurerm_resource_group.speeltuin-jnb.name
  network_security_group_name                = azurerm_network_security_group.jnb-apim-nsg.name
  access                                     = "Allow"
  description                                = ""
  destination_address_prefix                 = "VirtualNetwork"
  destination_port_range                     = "80"
  direction                                  = "Inbound"
  priority                                   = 100
  protocol                                   = "Tcp"
  source_address_prefix                      = var.home_ip
  source_port_range                          = "*"
}

resource "azurerm_network_security_rule" "apim-https-rule" {
  name                                       = "apim-https-rule"
  resource_group_name                        = azurerm_resource_group.speeltuin-jnb.name
  network_security_group_name                = azurerm_network_security_group.jnb-apim-nsg.name
  access                                     = "Allow"
  description                                = ""
  destination_address_prefix                 = "VirtualNetwork"
  destination_port_range                     = "443"
  direction                                  = "Inbound"
  priority                                   = 110
  protocol                                   = "Tcp"
  source_address_prefix                      = var.home_ip
  source_port_range                          = "*"
}

resource "azurerm_network_security_rule" "apim-management-https-rule" {
  name                                       = "apim-management-https-rule"
  resource_group_name                        = azurerm_resource_group.speeltuin-jnb.name
  network_security_group_name                = azurerm_network_security_group.jnb-apim-nsg.name
  access                                     = "Allow"
  description                                = ""
  destination_address_prefix                 = "VirtualNetwork"
  destination_port_range                     = "3443"
  direction                                  = "Inbound"
  priority                                   = 120
  protocol                                   = "Tcp"
  source_address_prefix                      = "ApiManagement"
  source_port_range                          = "*"
}

resource "azurerm_virtual_network" "jnb-vnet" {
  name                = "jnb-vnet"
  location            = azurerm_resource_group.speeltuin-jnb.location
  resource_group_name = azurerm_resource_group.speeltuin-jnb.name
  address_space       = ["10.0.0.0/16"]
}
