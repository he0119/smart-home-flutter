const String nearExpiredItemsQuery = r'''
query nearExpiredItems($nearExpiredTime: DateTime!, $now: DateTime!, $after: String) {
  nearExpiredItems: items(
    filters: {isDeleted: false, expiredAt: {gt: $now, lt: $nearExpiredTime}}
    after: $after
    first: 10
    order: {expiredAt: DESC}
  ) {
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
