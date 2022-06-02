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

param serverIpAddress string = '127.0.0.1'

output serverContainer object = {
  name: 'jnb-jakarta-soap-server-container'
  properties: {
    image: 'ninckblokje/jakarta-soap-service:latest'
    resources: {
      requests: {
        cpu: 1
        memoryInGB: 1
      }
    }
    environmentVariables: []
    ports: [
      {
        port: 9080
        protocol: 'TCP'
      }
    ]
  }
}

output serverContainerPort object = {
  port: 9080
  protocol: 'TCP'
}

output clientContainer object = {
  name: 'jnb-jakarta-soap-client-container'
  properties: {
    image: 'ninckblokje/jakarta-soap-client:latest'
    resources: {
      requests: {
        cpu: 1
        memoryInGB: 1
      }
    }
    environmentVariables: [
      {
        name: 'HELLOWORLD_WSDL_URL'
        value: 'http://${serverIpAddress}:9080/jakarta-soap-service/HelloWorldService?wsdl'
      }
      {
        name: 'PINGPONG_WSDL_URL'
        value: 'http://${serverIpAddress}:9080/jakarta-soap-service/PingPongService?wsdl'
      }
    ]
    ports: [
      {
        port: 9081
        protocol: 'TCP'
      }
    ]
  }
}

output clientContainerPort object = {
  port: 9081
  protocol: 'TCP'
}
