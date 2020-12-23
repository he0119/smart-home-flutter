const String topicsQuery = r"""
query topics($after: String) {
  topics(orderBy: "-is_open,-active_at", after: $after) {
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
        createdAt
        editedAt
        user {
          username
          email
        }
        comments(last: 1) {
          edges {
            node {
              createdAt
            }
          }
        }
      }
    }
  }
}
""";
