const String recentlyEditedItemsQuery = r'''
query recentlyEditedItems($after: String) {
  recentlyEditedItems: items(
    filters: {isDeleted: false}
    after: $after
    order: {editedAt: DESC}
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
        editedAt
      }
    }
  }
}
''';
