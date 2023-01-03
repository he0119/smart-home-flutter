const String searchQuery = r'''
query search($isDeleted: Boolean, $key: String!) {
  itemName: items(filters: {isDeleted: $isDeleted, name: {iContains: $key}}) {
    edges {
      node {
        id
        name
        description
      }
    }
  }
  itemDescription: items(
    filters: {isDeleted: $isDeleted, description: {iContains: $key}}
  ) {
    edges {
      node {
        id
        name
        description
      }
    }
  }
  storageName: storages(filters: {name: {iContains: $key}}) {
    edges {
      node {
        id
        name
        description
      }
    }
  }
  storageDescription: storages(filters: {description: {iContains: $key}}) {
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
