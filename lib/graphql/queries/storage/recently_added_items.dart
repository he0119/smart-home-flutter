const String recentlyAddedItemsQuery = r"""
query recentlyAddedItems($after: String) {
  recentlyAddedItems: items(after: $after, orderBy: "-date_added") {
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        id
        name
        description
        dateAdded
      }
    }
  }
}
""";
