const String expiredItemsQuery = r'''
query expiredItems($now: DateTime!, $after: String) {
  expiredItems: items(
    filters: {isDeleted: false, expiredAt: {lt: $now}}
    after: $after
    first: 10
    order: {expiredAt: DESC}
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
        expiredAt
      }
    }
  }
}
''';
