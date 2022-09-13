const String recentlyCreatedItemsQuery = r'''
query recentlyCreatedItems($after: String) {
  recentlyCreatedItems: items(
    filters: {isDeleted: false}
    after: $after
    order: {createdAt: DESC}
  ) {
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
