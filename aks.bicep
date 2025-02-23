/*  
  Copyright (c) 2025, ninckblokje
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

param adminUsername string = 'baron'

param homeIp string = '127.0.0.1/32'

@secure()
param publicKey string = ''

resource jnbAks 'Microsoft.ContainerService/managedClusters@2024-09-01' = {
  name: 'jnb-aks'
  location: location
  sku: {
    name: 'Base'
    tier: 'Free'
  }
  properties: {
    kubernetesVersion: '1.31'
    enableRBAC: true
    securityProfile: {
      imageCleaner: {
        enabled: true
        intervalHours: 24
      }
      workloadIdentity: {
        enabled: true
      }
    }
    oidcIssuerProfile: {
      enabled: true
    }
    servicePrincipalProfile: {
      clientId: 'msi'
    }
    addonProfiles: {
      azureKeyvaultSecretsProvider: {
        enabled: true
      }
      extensionManager: {
        enabled: true
      }
    }
    dnsPrefix: 'jnb-aks'
    publicNetworkAccess: 'Enabled'
    networkProfile: {
      ipFamilies: [
        'IPv4'
      ]
      dnsServiceIP: '10.0.9.10'
      networkPlugin: 'azure'
      podCidr: '10.0.7.0/24'
      serviceCidr: '10.0.9.0/24'
    }
    apiServerAccessProfile: {
      authorizedIPRanges: [
        homeIp
      ]
      disableRunCommand: true
    }
    agentPoolProfiles: [
      {
        name: 'jnbakslinux'
        count: 1
        vmSize: 'Standard_D2_v2'
        osType: 'Linux'
        mode: 'System'
        podSubnetID: resourceId('Microsoft.Network/virtualNetworks/subnets', 'jnb-vnet', 'AksPodSubnet')
        vnetSubnetID: resourceId('Microsoft.Network/virtualNetworks/subnets', 'jnb-vnet', 'AksPoolSubnet')
      }
    ]
    linuxProfile: {
      adminUsername: adminUsername
      ssh: {
        publicKeys: [
          {
            keyData: publicKey
          }
        ]
      }
    }
    storageProfile: {
      diskCSIDriver: {
        enabled: true
      }
      fileCSIDriver: {
        enabled: true
      }
      snapshotController: {
        enabled: true
      }
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}
