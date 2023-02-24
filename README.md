# my-azure-env

To install Azure bicep for use with Azure Powershell: `winget install -e --id Microsoft.Bicep`

A list of all templates available: https://docs.microsoft.com/en-us/azure/templates/

## Commands

To preview the modifications the bicep will make to the resource group: `New-AzResourceGroupDeployment -TemplateFile [BICEP_FILE] -TemplateParameterFile [PARAM_FILE] -ResourceGroupName [RESOURCE_GROUP] -WhatIf`
To execute the bicep file on a resource group: `New-AzResourceGroupDeployment -TemplateFile [BICEP_FILE] -TemplateParameterFile [PARAM_FILE] -ResourceGroupName [RESOURCE_GROUP] -Confirm`

To remove everything except the resources from `base.bicep`: `New-AzResourceGroupDeployment -TemplateFile base.bicep -TemplateParameterFile [PARAM_FILE] -ResourceGroupName [RESOURCE_GROUP] -Mode Complete -WhatIf`

## Parameters

A template file can be specified with configuration parameters.

### base.bicep parameters

| Parameter | Default value | Description |
|-|-|-|
| homeIp | 127.0.0.1/32 | IP address to whitelist |
| publicKey | | Public key for SSH access |

Example `base.params.json` file:

````json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "homeIp": {
            "value": "127.0.0.1/32"
        },
        "publicKey": {
            "value": ""
        }
    }
}
````

### keyvault.bicep parameters

| Parameter | Default value | Description |
|-|-|-|
| tenantId | | Tenant Id |

````json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "tenantId": {
            "value": ""
        }
    }
}
````
