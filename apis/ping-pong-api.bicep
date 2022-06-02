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

resource jnbApim 'Microsoft.ApiManagement/service@2021-08-01' existing = {
  name: 'jnb-apim'
}

resource jnbPingPongApi 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  name: 'ping-pong-api'
  parent: jnbApim
  properties:{
    displayName: 'PingPongAPI'
    description: 'Retrieves server information using ping - pong'
    path: ''
    protocols: [
      'https'
    ]
    serviceUrl: 'http://10.0.1.4:9081/jakarta-soap-client'
    subscriptionKeyParameterNames: {
      header: 'Ocp-Apim-Subscription-Key'
      query: 'subscription-key'
    }
    subscriptionRequired: true
  }
}

resource jnbPingPongProduct 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  name: 'ping-pong-product'
  parent: jnbApim
  properties: {
    approvalRequired: false
    displayName: 'PingPong'
    state: 'published'
    subscriptionRequired: true
  }
}

resource jnbPingPongProductApi 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  name: 'ping-pong-api'
  parent: jnbPingPongProduct
}

resource jnbPingPongProductDeveloperGroup 'Microsoft.ApiManagement/service/products/groups@2021-08-01' = {
  name: 'developers'
  parent: jnbPingPongProduct
}

resource jnbPingPongProductGuestGroup 'Microsoft.ApiManagement/service/products/groups@2021-08-01' = {
  name: 'guests'
  parent: jnbPingPongProduct
}
