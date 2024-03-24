param clusterName string
param dnsPrefix string
param location string
param privateClusterEnabled bool = true
param existingSubnetId string
param adminUserName string
param keydata string

resource aks 'Microsoft.ContainerService/managedClusters@2021-05-01' = {
  name: clusterName
  location: location
  properties: {
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 3
        vmSize: 'Standard_D2_v2'
        osType: 'Linux'
        mode: 'System'
        vnetSubnetID: existingSubnetId
        enableAutoScaling: true
        minCount: 2
        maxCount: 10

      }
    ]
    linuxProfile: {
      adminUsername: adminUserName
      ssh: {
        publicKeys: [
          {
            keyData: keydata
          }
        ]
      }
    }
    networkProfile: {
      networkPlugin: 'azure'
      serviceCidr: '10.0.0.0/16'
      dnsServiceIP: '10.0.0.10'
      dockerBridgeCidr: '172.17.0.1/16'
      loadBalancerSku: 'standard'
      outboundType: 'loadBalancer'
    }
    apiServerAccessProfile: {
      enablePrivateCluster: privateClusterEnabled
    }
  }
  identity: {
    type: 'SystemAssigned'
  }
}

output aks string = aks.id
output aksIdentity string= aks.identity.principalId
output aksIdentitytest object =aks.properties.identityProfile.kubeletidentity
