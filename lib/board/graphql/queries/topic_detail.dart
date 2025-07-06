const String topicDetailQuery = r'''
query topicDetail($topicId: ID!, $order: Ordering!, $after: String) {
  topic(id: $topicId) {
    id
    title
    description
    isClosed
    isPinned
    user {
      username
      avatarUrl
    }
    createdAt
    editedAt
  }
  comments(
    after: $after
    filters: {topic: {id: $topicId}, level: {exact: 0}}
    order: {createdAt: $order}
  ) {
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
          avatarUrl
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
''';
