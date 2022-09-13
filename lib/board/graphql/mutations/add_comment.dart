const String addCommentMutation = r'''
mutation addComment($input: AddCommentInput!) {
  addComment(input: $input) {
    ... on Comment {
      id
      body
      user {
        username
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
''';
