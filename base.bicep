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

param homeIp string = '127.0.0.1/32'

param location string = resourceGroup().location

@secure()
param publicKey string = ''

resource jnbPublicKey 'Microsoft.Compute/sshPublicKeys@2021-11-01' = {
  name: 'jnb-public-key'
  location: location
  properties: {
    publicKey: publicKey
  }
}

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

resource jnbWafNsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' = {
  name: 'jnb-waf-nsg'
  location: location

  resource WafHttpNsgRule 'securityRules' = {
    name: 'waf-http-rule'
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

  resource WafHttpsNsgRule 'securityRules' = {
    name: 'waf-https-rule'
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

  resource WafManagementNsgRule 'securityRules' = {
    name: 'waf-management-rule'
    properties: {
      access: 'Allow'
      direction: 'Inbound'
      priority: 120
      protocol: 'Tcp'
      sourceAddressPrefix: 'GatewayManager'
      sourcePortRange: '*'
      destinationAddressPrefix: '*'
      destinationPortRange: '65200-65535'
    }
  }
}

resource jnbVnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: 'jnb-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'DefaultSubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: jnbDefaultNsg.id
          }
        }
      }
      {
        name: 'ContainerSubnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: jnbDefaultNsg.id
          }
          delegations:[
            {
              name: 'Microsoft.ContainerInstance.containerGroups'
              properties: {
                serviceName: 'Microsoft.ContainerInstance/containerGroups'
              }
            }
          ]
        }
      }
      {
        name: 'ApimSubnet'
        properties: {
          addressPrefix: '10.0.2.0/24'
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: jnbApimNsg.id
          }
        }
      }
      {
        name: 'WafSubnet'
        properties: {
          addressPrefix: '10.0.3.0/24'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: jnbWafNsg.id
          }
          // applicationGatewayIpConfigurations: [
          //   {
          //     id: resourceId('Microsoft.Network/applicationGateways/gatewayIPConfigurations', 'jnb-waf', 'appGatewayIpConfig')
          //   }
          // ]
        }
      }
      {
        name: 'ContainerAppsSubnet'
        properties: {
          addressPrefix: '10.0.4.0/23'
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
          networkSecurityGroup: {
            id: jnbDefaultNsg.id
          }
        }
      }
    ]
  }
}
