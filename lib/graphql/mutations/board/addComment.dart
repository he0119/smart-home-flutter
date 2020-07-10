const String addCommentMutation = r"""
mutation addComment($input: AddCommentInput!) {
  addComment(input: $input) {
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
