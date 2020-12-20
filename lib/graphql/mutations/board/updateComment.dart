const String updateCommentMutation = r"""
mutation updateComment($input: UpdateCommentMutationInput!) {
  updateComment(input: $input) {
    comment {
      id
      body
      dateModified
    }
  }
}
""";
