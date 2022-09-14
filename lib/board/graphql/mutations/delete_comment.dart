const String deleteCommentMutation = r'''
mutation deleteComment($input: DeleteCommentInput!) {
  deleteComment(input: $input) {
    ... on Comment {
      id
    }
  }
}
''';
