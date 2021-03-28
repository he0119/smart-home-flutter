const String expiredItemsQuery = r'''
query expiredItems($now: DateTime!, $after: String) {
  expiredItems: items(isDeleted: false, after: $after, expiredAt_Lt: $now, orderBy: "-expired_at") {
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        id
        name
        description
        expiredAt
      }
    }
  }
}
''';
