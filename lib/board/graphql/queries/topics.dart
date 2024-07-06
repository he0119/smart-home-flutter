const String topicsQuery = r'''
query topics($after: String) {
  topics(after: $after, order: {isPinned: DESC, isClosed: ASC, activeAt: DESC}) {
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        id
        title
        description
        isClosed
        isPinned
        createdAt
        editedAt
        user {
          username
          avatarUrl
        }
        comments(first: 1, order: {createdAt: DESC}) {
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
