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

param jnbVnetGuid string

resource jnbVnet 'Microsoft.Network/virtualNetworks@2021-08-01' existing = {
  name: 'jnb-vnet'
}

resource jnbDefaultSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  name: 'DefaultSubnet'
  parent: jnbVnet
}

resource jnbLogicAppsServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: 'jnb-logic-apps-service-plan'
  location: location
}

resource jnbLogicApps 'Microsoft.Web/sites@2024-04-01' = {
  name: 'jnb-logic-apps'
  location: location
  kind: 'functionapp,workflowapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    enabled: true
    serverFarmId: jnbLogicAppsServicePlan.id
    siteConfig: {
      localMySqlEnabled: false
    }
  }

  resource ftpPublishingPolicy 'basicPublishingCredentialsPolicies' = {
    name: 'ftp'
    properties: {
      allow: false
    }
  }

  resource scmPublishingPolicy 'basicPublishingCredentialsPolicies' = {
    name: 'scm'
    properties: {
      allow: false
    }
  }

  resource webConfig 'config' = {
    name: 'web'
    properties: {
      vnetName: '${jnbVnetGuid}_DefaultSubnet'
      vnetRouteAllEnabled: true
    }
  }

  resource azureWebsitesHostnameBinding 'hostNameBindings' = {
    name: 'jnb-logic-apps.azurewebsites.net'
    properties: {
      siteName: 'jnb-logic-apps'
      hostNameType: 'Verified'
    }
  }

  resource jnbVnetConnection 'virtualNetworkConnections' = {
    name: '${jnbVnetGuid}_DefaultSubnet'
    properties: {
      vnetResourceId: jnbDefaultSubnet.id
      isSwift: true
    }
  }
}
