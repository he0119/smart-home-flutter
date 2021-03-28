const String nearExpiredItemsQuery = r'''
query nearExpiredItems($nearExpiredTime: DateTime!, $now: DateTime!, $after: String) {
  nearExpiredItems: items(isDeleted: false, after: $after, expiredAt_Gt: $now, expiredAt_Lt: $nearExpiredTime, orderBy: "-expired_at") {
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
