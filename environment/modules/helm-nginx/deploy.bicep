param location string = resourceGroup().location

resource aci 'Microsoft.ContainerInstance/containerGroups@2018-10-01' = {
  name: 'helm-install-nginx'
  location: location
  properties: {
    containers: [
      {
        name: 'helm'
        properties: {
          image: 'alpine/helm:3.6.3'
          command: [
            '/bin/sh'
            '-c'
            'helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx && helm install my-release ingress-nginx/ingress-nginx'
          ]
          resources: {
            requests: {
              cpu: 1
              memoryInGB: 2
            }
          }
        }
      }
    ]
    osType: 'Linux'
    restartPolicy: 'OnFailure'
  }
}
