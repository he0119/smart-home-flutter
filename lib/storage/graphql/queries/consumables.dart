const String consumablesQuery = r'''
query consumables($after: String) {
  consumables: items(
    after: $after
    filters: {isDeleted: false, consumables: true}
  ) {
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        id
        name
        consumables(filters: {isDeleted: false}) {
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
