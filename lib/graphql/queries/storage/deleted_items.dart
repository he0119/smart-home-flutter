const String deletedItemsQuery = r"""
query deletedItems($after: String) {
  deletedItems: items(isDeleted: true, after: $after, orderBy: "-deleted_at") {
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
""";
