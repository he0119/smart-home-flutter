const String deletedItemsQuery = r'''
query deletedItems($after: String) {
  deletedItems: items(
    filters: {isDeleted: true}
    after: $after
    order: {deletedAt: DESC}
  ) {
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        id
        name
        description
        deletedAt
      }
    }
  }
}
''';
