const String nearExpiredItemsQuery = r"""
query nearExpiredItems($nearExpiredTime: DateTime!, $now: DateTime!, $after: String) {
  nearExpiredItems: items(after: $after, expirationDate_Gt: $now, expirationDate_Lt: $nearExpiredTime, orderBy: "-expiration_date") {
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
