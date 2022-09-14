const String recentlyCreatedItemsQuery = r'''
query recentlyCreatedItems($after: String) {
  recentlyCreatedItems: items(
    filters: {isDeleted: false}
    after: $after
    order: {createdAt: DESC}
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
        createdAt
      }
    }
  }
}
''';
