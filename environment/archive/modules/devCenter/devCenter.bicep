param location string = resourceGroup().location
param type string = 'SystemAssigned'
param devcentername string
param law string
//param existingImageGalleryName string

resource dc 'Microsoft.DevCenter/devcenters@2022-11-11-preview' = {
  name: devcentername
  location: location
  identity: {
    type: type
  }
}
output identitytype string = dc.identity.principalId
output dcnid string = dc.id

 resource dcDiags 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
   name: dc.name
   scope: dc
   properties: {
     workspaceId: logs.id
     logs: [
       {
         enabled: true
         categoryGroup: 'allLogs'
       }
       {
         enabled: true
         categoryGroup: 'audit'
       }
     ]
   }
 }

 resource logs 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
   name: law
   location: location
   properties: {
     sku: {
       name: 'PerGB2018'
     }
     retentionInDays: 30
     workspaceCapping: {
       dailyQuotaGb: 1
    }
   }
 }

// Link to an existing Image Gallery in another resource group

// resource gallery 'Microsoft.Compute/galleries@2022-03-03' existing = {
//    scope: resourceGroup('xmew1-dop-s-stamp-d-rg-001')
//    name: existingImageGalleryName
//  }

// output galleryid string = gallery.id

//  resource dcGallery 'Microsoft.DevCenter/devcenters/galleries@2022-11-11-preview' = {
//   parent: dc
//   name: existingImageGalleryName
//   properties: {
//     galleryResourceId: gallery.id
//   }
//   //dependsOn: [dcIdRbac]
// }

//var readerRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'acdd72a7-3385-48ef-bd42-f606fba81ae7')
// var contribRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'b24988ac-6180-42a0-ab88-20f7382dd24c')
// resource dcIdRbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
//   name: guid(gallery.id, contribRoleId, dc.id)
//   //scope: '/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-s-stamp-d-rg-001/providers/Microsoft.Compute/galleries/xmew1dopsstampdcomputegallery001'
//   properties: {
//     roleDefinitionId: contribRoleId
//     principalId: dc.identity.principalId
//     principalType: 'ServicePrincipal'
//   }
// }
output devcentername string = dc.name
output dcid string = dc.id
