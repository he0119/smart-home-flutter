const String recentlyUpdatedItemsQuery = r"""
query recentlyUpdatedItems($after: String) {
  recentlyUpdatedItems: items(after: $after, orderBy: "-update_date") {
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        id
        name
        description
        updateDate
      }
    }
  }
}
""";
