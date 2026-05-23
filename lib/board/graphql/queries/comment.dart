const String commentQuery = r'''
query comment($commentId: ID!) {
  node(id: $commentId) {
    ... on CommentType {
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
      topic {
        id
        title
      }
    }
  }
}
''';
