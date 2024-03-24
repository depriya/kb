param devcentername string
param projectTeamName string = 'developers'
param adeProjectUser string = ''

resource dc 'Microsoft.DevCenter/devcenters@2022-11-11-preview' existing = {
  name: devcentername
}

resource project 'Microsoft.DevCenter/projects@2022-11-11-preview' existing = {
  name: projectTeamName
}


param environmentTypes array = ['Dev', 'Test', 'Staging']
resource envs 'Microsoft.DevCenter/devcenters/environmentTypes@2022-11-11-preview' existing = [for envType in environmentTypes :{
  name: envType
  parent: dc
}] 


//param deploymentTargetId string = '${subscription().id}/devcenter-deploy-bucket'
param deploymentTargetId string = subscription().id

var rbacRoleId = {
  owner: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  deployenvuser: '18e40d4e-8d2e-438d-97e1-9528336e149c'
}
output dti string = deploymentTargetId

resource projectAssign 'Microsoft.DevCenter/projects/environmentTypes@2022-11-11-preview' =  [for envType in environmentTypes : {
  name: envType
  parent: project
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    creatorRoleAssignment: {
      roles : {
        '${rbacRoleId.contributor}': {}
      }
    }
    status: 'Enabled'
    deploymentTargetId: deploymentTargetId
  }
}]

var adeUserRoleId = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', rbacRoleId.deployenvuser) 
resource projectUserRbac 'Microsoft.Authorization/roleAssignments@2022-04-01' = if(!empty(adeProjectUser)) {
  scope: project
  name: guid(project.id, adeUserRoleId, adeProjectUser)
  properties: {
    roleDefinitionId: adeUserRoleId
    principalType: 'User'
    principalId: adeProjectUser
  }
}
