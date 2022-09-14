const String updateCommentMutation = r'''
mutation updateComment($input: UpdateCommentInput!) {
  updateComment(input: $input) {
    ... on Comment {
      id
      body
      editedAt
    }
  }
}
''';
