targetScope = 'subscription'

param resourcePrefix string = 'funcidentitydemo'
param location string = 'northeurope'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: '${resourcePrefix}rg'
  location: location
}

module resources 'resources.bicep' = {
  scope: resourceGroup
  name: '${resourcePrefix}-resources'
  params: {
    resourcePrefix: resourcePrefix
    location: location
  }
}
