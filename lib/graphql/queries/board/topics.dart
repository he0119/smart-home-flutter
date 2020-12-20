const String topicsQuery = r"""
query topics($after: String) {
  topics(orderBy: "-is_open,-date_active", after: $after) {
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
        dateCreated
        dateModified
        user {
          username
          email
        }
        comments(last: 1) {
          edges {
            node {
              dateCreated
            }
          }
        }
      }
    }
  }
}
""";
