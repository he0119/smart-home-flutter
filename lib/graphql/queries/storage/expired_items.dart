const String expiredItemsQuery = r"""
query expiredItems($now: DateTime!, $after: String) {
  expiredItems: items(after: $after, expirationDate_Lt: $now, orderBy: "-expiration_date") {
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        id
        name
        description
        expirationDate
      }
    }
  }
}
""";
