const String topicsQuery = r'''
query topics($after: String) {
  topics(after: $after, order: {activeAt: DESC}) {
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
          avatarUrl
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
