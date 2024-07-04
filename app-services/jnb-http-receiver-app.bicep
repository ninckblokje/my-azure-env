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

param homeIp string = '127.0.0.1'

resource jnbAppServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: 'jnb-app-service-plan'
  location: location
  properties: {
    reserved: true
  }
  kind: 'linux'
  sku: {
    name: 'F1'
    tier: 'Free'
  }
}

resource jnbHttpReceiverApp 'Microsoft.Web/sites@2023-12-01' = {
  name: 'jnb-http-receiver-app'
  location: location
  properties: {
    clientAffinityEnabled: false
    httpsOnly: true
    publicNetworkAccess: 'Enabled'
    reserved: true
    serverFarmId: jnbAppServicePlan.id
    siteConfig: {
      linuxFxVersion: 'DOCKER|ninckblokje/http-receiver:latest'
      appSettings: [
        {
          name: 'WEBSITES_PORT'
          value: '8888'
        }
      ]
      ftpsState: 'Disabled'
      ipSecurityRestrictionsDefaultAction: 'Deny'
      ipSecurityRestrictions: [
        {
          ipAddress: 'Any'
          action: 'Deny'
          name: 'DenyAll'
          priority: 2147483647
        }
        {
          ipAddress: homeIp
          action: 'Allow'
          name: 'AllowHomeIp'
          priority: 1000
        }
      ]
      scmIpSecurityRestrictionsDefaultAction: 'Deny'
      scmIpSecurityRestrictions: [
        {
          ipAddress: 'Any'
          action: 'Deny'
          name: 'DenyAll'
          priority: 2147483647
        }
        {
          ipAddress: homeIp
          action: 'Allow'
          name: 'AllowHomeIp'
          priority: 1000
        }
      ]
    }
  }

  resource ftpBasicPublishingCredentialsPolicies 'basicPublishingCredentialsPolicies' = {
    name: 'ftp'
    properties: {
      allow: false
    }
  }

  resource scmBasicPublishingCredentialsPolicies 'basicPublishingCredentialsPolicies' = {
    name: 'scm'
    properties: {
      allow: false
    }
  }

  resource webConfig 'config' = {
    name: 'web'
    properties: {
      scmIpSecurityRestrictionsDefaultAction: 'Deny'
      scmIpSecurityRestrictionsUseMain: true
    }
  }
}
