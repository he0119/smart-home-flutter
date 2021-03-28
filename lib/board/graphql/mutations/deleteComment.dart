const String deleteCommentMutation = r'''
mutation deleteComment($input: DeleteCommentMutationInput!) {
  deleteComment(input: $input) {
    clientMutationId
  }
}
''';
