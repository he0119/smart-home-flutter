const String consumablesQuery = r'''
query consumables($after: String) {
  consumables: items(isDeleted: false, consumables: true, after: $after) {
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        id
        name
        consumables(isDeleted: false) {
          edges {
            node {
              id
              name
              number
              expiredAt
            }
          }
        }
      }
    }
  }
}
''';
