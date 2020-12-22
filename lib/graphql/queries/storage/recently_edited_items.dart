const String recentlyEditedItemsQuery = r"""
query recentlyEditedItems($after: String) {
  recentlyEditedItems: items(isDeleted: false, after: $after, orderBy: "-edited_at") {
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
""";
