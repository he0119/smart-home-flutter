const String updateCommentMutation = r"""
mutation updateComment($input: UpdateCommentInput!) {
  updateComment(input: $input) {
    comment {
      id
      body
      dateModified
    }
  }
}
""";
