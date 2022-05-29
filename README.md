# my-azure-env

To install Azure bicep for use with Azure Powershell: `winget install -e --id Microsoft.Bicep`

## Commands

To preview the modifications the bicep will make to the resource group: `New-AzResourceGroupDeployment -TemplateFile [BICEP_FILE] -ResourceGroupName [RESOURCE_GROUP] -WhatIf`
To execute the bicep file on a resource group: `New-AzResourceGroupDeployment -TemplateFile [BICEP_FILE] -ResourceGroupName [RESOURCE_GROUP] -Confirm`

## Parameters

A template file can be specified with configuration parameters.

### base.bicep parameters

| Parameter | Default value | Description |
|-|-|-|
| homeIp | 127.0.0.1/32 | IP address to whitelist |
| publicKey | | Public key for SSH access |
