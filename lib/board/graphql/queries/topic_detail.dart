const String topicDetailQuery = r'''
query topicDetail($topicId: GlobalID!, $order: Ordering!, $after: String) {
  topic(id: $topicId) {
    id
    title
    description
    isOpen
    isPin
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
