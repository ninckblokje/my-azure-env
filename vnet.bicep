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

param vnetIpRange string = '10.0.0.0/16'

resource jnbDefaultNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' existing = {
  name: 'jnb-default-nsg'
}

resource jnbApimNsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' existing = {
  name: 'jnb-apim-nsg'
}

resource jnbWafNsg 'Microsoft.Network/networkSecurityGroups@2021-08-01' existing = {
  name: 'jnb-waf-nsg'
}

resource jnbVnet 'Microsoft.Network/virtualNetworks@2021-08-01' = {
  name: 'jnb-vnet'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetIpRange
      ]
    }
  }

  resource jnbDefaultSubnet 'subnets' = {
    name: 'DefaultSubnet'
    properties: {
      addressPrefix: '10.0.0.0/24'
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
      networkSecurityGroup: {
        id: jnbDefaultNsg.id
      }
      serviceEndpoints: [
        {
          service: 'Microsoft.Storage'
        }
      ]
    }
  }

  resource jnbContainerSubnet 'subnets' = {
    name: 'ContainerSubnet'
    dependsOn: [ jnbDefaultSubnet ]
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

  resource jnbApimSubnet 'subnets' = {
    name: 'ApimSubnet'
    dependsOn: [ jnbContainerSubnet ]
    properties: {
      addressPrefix: '10.0.2.0/24'
      privateEndpointNetworkPolicies: 'Enabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
      networkSecurityGroup: {
        id: jnbApimNsg.id
      }
    }
  }

  resource jnbWafSubnet 'subnets' = {
    name: 'WafSubnet'
    dependsOn: [ jnbApimSubnet ]
    properties: {
      addressPrefix: '10.0.3.0/24'
      privateEndpointNetworkPolicies: 'Disabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
      networkSecurityGroup: {
        id: jnbWafNsg.id
      }
    }
  }

  resource jnbContainerAppsSubnet 'subnets' = {
    name: 'ContainerAppsSubnet'
    dependsOn: [ jnbWafSubnet ]
    properties: {
      addressPrefix: '10.0.4.0/23'
      privateEndpointNetworkPolicies: 'Disabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
      networkSecurityGroup: {
        id: jnbDefaultNsg.id
      }
    }
  }

  resource jnbAsbSubnet 'subnets' = {
    name: 'AsbSubnet'
    dependsOn: [ jnbContainerAppsSubnet ]
    properties: {
      addressPrefix: '10.0.6.0/24'
      privateEndpointNetworkPolicies: 'Disabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
      networkSecurityGroup: {
        id: jnbDefaultNsg.id
      }
      serviceEndpoints: [
        {
          service: 'Microsoft.ServiceBus'
        }
      ]
    }
  }

  resource jnbAksPodSubnet 'subnets' = {
    name: 'AksPodSubnet'
    dependsOn: [ jnbAsbSubnet ]
    properties: {
      addressPrefix: '10.0.7.0/24'
      privateEndpointNetworkPolicies: 'Disabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
      networkSecurityGroup: {
        id: jnbDefaultNsg.id
      }
    }
  }

  resource jnbAksPoolSubnet 'subnets' = {
    name: 'AksPoolSubnet'
    dependsOn: [ jnbAksPodSubnet ]
    properties: {
      addressPrefix: '10.0.8.0/24'
      privateEndpointNetworkPolicies: 'Disabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
      networkSecurityGroup: {
        id: jnbDefaultNsg.id
      }
      delegations: [
        {
          name: 'aks-delegation'
          properties: {
            serviceName: 'Microsoft.ContainerService/managedClusters'
          }
        }
      ]
    }
  }

  resource jnbAksServiceSubnet 'subnets' = {
    name: 'AksServiceSubnet'
    dependsOn: [ jnbAksPoolSubnet ]
    properties: {
      addressPrefix: '10.0.9.0/24'
      privateEndpointNetworkPolicies: 'Disabled'
      privateLinkServiceNetworkPolicies: 'Enabled'
      networkSecurityGroup: {
        id: jnbDefaultNsg.id
      }
    }
  }
}
