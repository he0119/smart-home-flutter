const String rootStorageQuery = r'''
query rootStorage($after: String) {
  rootStorage: storages(level: 0, after: $after) {
    pageInfo {
      hasNextPage
      endCursor
    }
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
