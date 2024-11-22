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

param location string = resourceGroup().location

param homeIp string = '127.0.0.1/32'
param vnetIpRange string = '10.0.0.0/16'
param wafPrivateIpAddress string = '10.0.3.254'

@secure()
param publicKey string = ''

resource jnbPublicKey 'Microsoft.Compute/sshPublicKeys@2021-11-01' = {
  name: 'jnb-public-key'
  location: location
  properties: {
    publicKey: publicKey
  }
}

module jnbPipModule 'pip.bicep' = {
  name: 'jnb-pip-module'
}

module jnbNsgModule 'nsg.bicep' = {
  name: 'jnb-nsg-module'
  params: {
    homeIp: homeIp
    vnetIpRange: vnetIpRange
    wafPrivateIpAddress: wafPrivateIpAddress
  }
}

module jnbManagementIdentityModule 'managed-identity.bicep' = {
  name: 'jnb-management-identity-module'
}
