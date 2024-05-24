/*
  Copyright (c) 2024, ninckblokje
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

param location string = resourceGroup().location

param homeIp string = '127.0.0.1/32'
param vnetIpRange string = '10.0.0.0/16'
param wafPrivateIpAddress string = '10.0.3.254'

resource jnbDefaultNsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: 'jnb-default-nsg'
  location: location

  resource allowHomeNsgRule 'securityRules' = {
    name: 'allow-home-rule'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefixes: [
        homeIp
      ]
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 100
      direction: 'Inbound'
    }
  }
}

resource jnbApimNsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: 'jnb-apim-nsg'
  location: location

  resource ApimHttpNsgRule 'securityRules' = {
    name: 'apim-http-rule'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '80'
      sourceAddressPrefixes: [
        homeIp
      ]
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 100
      direction: 'Inbound'
    }
  }

  resource ApimHttpsNsgRule 'securityRules' = {
    name: 'apim-https-rule'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefixes: [
        homeIp
      ]
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 110
      direction: 'Inbound'
    }
  }

  resource ApimManagementHttpsNsgRule 'securityRules' = {
    name: 'apim-management-https-rule'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '3443'
      sourceAddressPrefix: 'ApiManagement'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 120
      direction: 'Inbound'
    }
  }
}

resource jnbWafPip 'Microsoft.Network/publicIPAddresses@2021-08-01' existing = {
  name: 'jnb-waf-pip'
}

resource jnbWafNsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: 'jnb-waf-nsg'
  location: location

  resource WafPrivateHttpNsgRule 'securityRules' = {
    name: 'waf-private-http-rule'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '80'
      sourceAddressPrefixes: [
        vnetIpRange
      ]
      destinationAddressPrefixes: [
        wafPrivateIpAddress
      ]
      access: 'Allow'
      priority: 200
      direction: 'Inbound'
    }
  }

  resource WafPublicHttpNsgRule 'securityRules' = {
    name: 'waf-public-http-rule'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '80'
      sourceAddressPrefixes: [
        homeIp
      ]
      destinationAddressPrefixes: [
        jnbWafPip.properties.ipAddress
      ]
      access: 'Allow'
      priority: 210
      direction: 'Inbound'
    }
  }

  resource WafPrivateHttpsNsgRule 'securityRules' = {
    name: 'waf-private-https-rule'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefixes: [
        vnetIpRange
      ]
      destinationAddressPrefixes: [
        wafPrivateIpAddress
      ]
      access: 'Allow'
      priority: 300
      direction: 'Inbound'
    }
  }

  resource WafPublicHttpsNsgRule 'securityRules' = {
    name: 'waf-public-https-rule'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefixes: [
        homeIp
      ]
      destinationAddressPrefixes: [
        jnbWafPip.properties.ipAddress
      ]
      access: 'Allow'
      priority: 310
      direction: 'Inbound'
    }
  }

  resource WafManagementNsgRule 'securityRules' = {
    name: 'waf-public-management-rule'
    properties: {
      access: 'Allow'
      direction: 'Inbound'
      priority: 100
      protocol: 'Tcp'
      sourceAddressPrefix: 'GatewayManager'
      sourcePortRange: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: '65200-65535'
    }
  }

}
