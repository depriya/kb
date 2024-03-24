param devcentername string
param environmentName string = 'sandbox'
//param projectTeamName string = '' //required for project
param catalogName string = 'oemcatalog'
param catalogRepoUri string = 'https://github.com/avl-sdv/DevOpsPilot.workflow_Symphony.git'
//param adeProjectUser string = '' //required for project
param secretUri string
param location string = 'westeurope'
//param type string
//param existingImageGalleryName string
@secure()
@description('A PAT token is required, even for public repos')
param catalogRepoPat string

resource dc 'Microsoft.DevCenter/devcenters@2022-11-11-preview' = {
  name: devcentername
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}
//required for project
//resource project 'Microsoft.DevCenter/projects@2022-11-11-preview' existing = {
 //name: projectTeamName
//}


resource env 'Microsoft.DevCenter/devcenters/environmentTypes@2022-11-11-preview' = {
  name: environmentName
  parent: dc
}

resource catalog 'Microsoft.DevCenter/devcenters/catalogs@2022-11-11-preview' = {
  name: catalogName
  parent: dc
  properties: {
    gitHub: {
      uri: catalogRepoUri
      branch: 'main'
      secretIdentifier: !empty(catalogRepoPat) ? secretUri : null
      //path: '/Environments'
    }
  }
}

param environmentTypes array = ['Dev', 'Test', 'Staging']
resource envs 'Microsoft.DevCenter/devcenters/environmentTypes@2022-11-11-preview' = [for envType in environmentTypes :{
  name: envType
  parent: dc
}]

// Link to an existing Image Gallery in another resource group

// resource gallery 'Microsoft.Compute/galleries@2022-03-03' existing = {
//   scope: resourceGroup('xmew1-dop-s-stamp-d-rg-001')
//   name: existingImageGalleryName
// }
// output galleryResourceId string = gallery.id

//required for project creation

//param deploymentTargetId string = subscription().id



// //var rbacRoleId = {
//   owner: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
//   contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
//   deployenvuser: '18e40d4e-8d2e-438d-97e1-9528336e149c'
// }
// output dti string = deploymentTargetId

// resource projectAssign 'Microsoft.DevCenter/projects/environmentTypes@2022-11-11-preview' =  [for envType in environmentTypes : {
//   name: envType
//   parent: project
//   identity: {
//     type: type
//   }
//   properties: {
//     creatorRoleAssignment: {
//       roles : {
//         '${rbacRoleId.contributor}': {}
//       }
//     }
//     status: 'Enabled'
//     deploymentTargetId: deploymentTargetId
//   }
// }]

// var adeUserRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', rbacRoleId.deployenvuser) 
// resource projectUserRbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = if(!empty(adeProjectUser)) {
//   scope: project
//   name: guid(project.id, adeUserRoleId, adeProjectUser)
//   properties: {
//     roleDefinitionId: adeUserRoleId
//     principalType: 'User'
//     principalId: adeProjectUser
//   }
// }
