const String recentlyCreatedItemsQuery = r'''
query recentlyCreatedItems($after: String) {
  recentlyCreatedItems: items(isDeleted: false, after: $after, orderBy: "-created_at") {
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
