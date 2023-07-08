param resourcePrefix string
param location string = resourceGroup().location

resource userIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: '${resourcePrefix}id'
  location: location
}

resource servicebus 'Microsoft.ServiceBus/namespaces@2022-10-01-preview' = {
  name: '${resourcePrefix}bus'
  location: location
}

resource servicebusTopic 'Microsoft.ServiceBus/namespaces/topics@2022-10-01-preview' = {
  name: 'demotopic'
  parent: servicebus
}

resource servicebusSubscription 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2022-10-01-preview' = {
  name: 'demosub'
  parent: servicebusTopic
}

var azureServiceBusDataOwnerRoleId = '090c5cfd-751d-490a-894a-3ce6f1109419'

resource subscriptionRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid('${servicebus.name}${servicebusSubscription.name}', userIdentity.name, azureServiceBusDataOwnerRoleId)
  scope: servicebusSubscription
  properties: {
    principalId: userIdentity.properties.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', azureServiceBusDataOwnerRoleId)
    principalType: 'ServicePrincipal'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: '${resourcePrefix}sa'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'Storage'
  properties: {
    supportsHttpsTrafficOnly: true
    defaultToOAuthAuthentication: true
  }
}

var storageBlobDataOwnerRoleId = 'b7e6dc6d-f1e8-4753-8033-0f276bb0955b'

resource storageRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccount.name, functionApp.name, storageBlobDataOwnerRoleId)
  scope: storageAccount
  properties: {
    principalId: functionApp.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', storageBlobDataOwnerRoleId)
    principalType: 'ServicePrincipal'
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${resourcePrefix}ai'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Request_Source: 'rest'
  }
}

resource hostingPlan 'Microsoft.Web/serverfarms@2021-03-01' = {
  name: '${resourcePrefix}plan'
  location: location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource functionApp 'Microsoft.Web/sites@2021-03-01' = {
  name: '${resourcePrefix}func'
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${userIdentity.id}': {}
    }
  }
  properties: {
    serverFarmId: hostingPlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'dotnet'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: applicationInsights.properties.InstrumentationKey
        }
        {
          name: 'AzureWebJobsStorage__accountName'
          value: storageAccount.name
        }
        {
          name: 'demoservicebus__fullyQualifiedNamespace'
          value: '${servicebus.name}.servicebus.windows.net'
        }
        {
          name: 'demoservicebus__credential'
          value: 'managedidentity'
        }
        {
          name: 'demoservicebus__clientID'
          value: userIdentity.properties.clientId
        }
      ]
      ftpsState: 'FtpsOnly'
      minTlsVersion: '1.2'
    }
    httpsOnly: true
  }
}
