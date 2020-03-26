const String updateCommentMutation = r"""
mutation updateComment($input: UpdateCommentInput!) {
  updateComment(input: $input) {
    comment {
      __typename
      id
      body
      dateModified
    }
  }
}
""";
