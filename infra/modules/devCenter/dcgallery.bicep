param devcentername string
param existingImageGalleryName string
resource dc 'Microsoft.DevCenter/devcenters@2022-11-11-preview' existing = {
  name: devcentername
}

resource dcGallery 'Microsoft.DevCenter/devcenters/galleries@2022-11-11-preview' = {
  name: existingImageGalleryName
  parent: dc
  properties: {
    galleryResourceId: '/subscriptions/db401b47-f622-4eb4-a99b-e0cebc0ebad4/resourceGroups/xmew1-dop-s-stamp-d-rg-001/providers/Microsoft.Compute/galleries/xmew1dopsstampdcomputegallery001'
    //galleryResourceId: resourceId('Microsoft.Compute/galleries', 'xmew1dopsstampdcomputegallery001')
  }
}
