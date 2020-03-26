const String updateCommentMutation = r"""
mutation updateComment($input: UpdateCommentInput!) {
  updateComment(input: $input) {
    comment {
      __typename
      id
      body
      user {
        username
      }
      dateCreated
      dateModified
      parent {
        id
      }
      replyTo {
        username
      }
    }
  }
}
""";
