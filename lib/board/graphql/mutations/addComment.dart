const String addCommentMutation = r'''
mutation addComment($input: AddCommentMutationInput!) {
  addComment(input: $input) {
    comment {
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
