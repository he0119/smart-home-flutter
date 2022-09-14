const String searchQuery = r'''
query search($isDeleted: Boolean, $key: String!) {
  itemName: items(filters: {isDeleted: $isDeleted, name: {contains: $key}}) {
    edges {
      node {
        id
        name
        description
      }
    }
  }
  itemDescription: items(
    filters: {isDeleted: $isDeleted, description: {contains: $key}}
  ) {
    edges {
      node {
        id
        name
        description
      }
    }
  }
  storageName: storages(filters: {name: {contains: $key}}) {
    edges {
      node {
        id
        name
        description
      }
    }
  }
  storageDescription: storages(filters: {description: {contains: $key}}) {
    edges {
      node {
        id
        name
        description
      }
    }
  }
}
''';
