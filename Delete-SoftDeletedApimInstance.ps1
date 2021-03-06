# Copyright (c) 2022, ninckblokje
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# * Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.

# * Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $SubscriptionId,

    [Parameter()]
    [Switch]
    $Delete = $false
)

if ($Delete) {
    Write-Error "Deleting soft-deleted jnb-apim from subscription $SubscriptionId"
} else {
    Write-Host "Getting soft-deleted jnb-apim from subscription $SubscriptionId"
}

$token = Get-AzAccessToken
$request = @{
    Uri     = "https://management.azure.com/subscriptions/${SubscriptionId}/providers/Microsoft.ApiManagement/locations/westeurope/deletedservices/jnb-apim?api-version=2021-08-01"
    Method  = ($Delete ? 'DELETE' : 'GET')
    Headers = @{
        Authorization = "Bearer $($token.token)"
    }
}

Invoke-RestMethod @request
