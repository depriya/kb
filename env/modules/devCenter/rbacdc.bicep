//Assigns the Devcenter identity permission to deploy to the Environment Resource Group
param existingImageGalleryName string
param principalId string
//param devcenterName string
resource gallery 'Microsoft.Compute/galleries@2022-03-03' existing = {
  //scope: resourceGroup('xmew1-dop-s-stamp-d-rg-001')
  name: existingImageGalleryName
}
var Role = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6')

resource rbacSecretUser 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  scope: gallery
  name: guid(gallery.id, principalId, Role)
  properties: {
    roleDefinitionId: Role
    principalType: 'ServicePrincipal'
    principalId: principalId
   
  }
}


