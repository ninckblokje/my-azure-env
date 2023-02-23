/*  
  Copyright (c) 2023, ninckblokje
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

// param jnbContainerAppsDomainName string

// param jnbContainerAppsIpAddress string

param location string = 'global'

param jnbContainerAppsDnsZoneName string

param jnbContainerAppsEnvIpAdress string

resource jnbVnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: 'jnb-vnet'
}

resource jnbContainerAppsDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: jnbContainerAppsDnsZoneName
  location: location
}

resource jnbContainerAppsDnsZoneJnbVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'jnb-container-apps-jnb-vnet-link'
  location: location
  parent: jnbContainerAppsDnsZone
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: jnbVnet.id
    }
  }
}

resource jnbContainerAppsDnsZoneSoaRecord 'Microsoft.Network/privateDnsZones/SOA@2020-06-01' = {
  name: '@'
  parent: jnbContainerAppsDnsZone
  properties: {
    ttl: 3600
    soaRecord: {
      email: 'azureprivatedns-host.microsoft.com'
      expireTime: 2419200
      host: 'azureprivatedns.net'
      minimumTtl: 10
      refreshTime: 3600
      retryTime: 300
      serialNumber: 1
    }
  }
}

resource jnbContainerAppsDnsZoneWildcardRecord 'Microsoft.Network/privateDnsZones/A@2020-06-01' = {
  name: '*'
  parent: jnbContainerAppsDnsZone
  properties: {
    ttl: 3600
    aRecords: [
      {
        ipv4Address: jnbContainerAppsEnvIpAdress
      }
    ]
  }
}
