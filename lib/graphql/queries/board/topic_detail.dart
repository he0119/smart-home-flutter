const String topicDetailQuery = r"""
query topicDetail($topicId: ID!, $orderBy: String!, $after: String) {
  topic(id: $topicId) {
    id
    title
    description
    isOpen
    isPin
    user {
      username
      email
    }
    createdAt
    editedAt
  }
  comments(topic: $topicId, level: 0, orderBy: $orderBy, after: $after) {
    pageInfo {
      hasNextPage
      endCursor
    }
    edges {
      node {
        id
        body
        user {
          username
          email
        }
        createdAt
        editedAt
        parent {
          id
        }
        replyTo {
          username
        }
      }
    }
  }
}
""";
