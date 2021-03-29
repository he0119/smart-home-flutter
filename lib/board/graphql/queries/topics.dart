const String topicsQuery = r'''
query topics($after: String) {
  topics(orderBy: "-is_pin,-is_open,-active_at", after: $after) {
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        id
        title
        description
        isOpen
        isPin
        createdAt
        editedAt
        user {
          username
          email
        }
        comments(last: 1) {
          edges {
            node {
              id
              createdAt
            }
          }
        }
      }
    }
  }
}
''';
