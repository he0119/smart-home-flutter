const String deleteCommentMutation = r"""
mutation deleteComment($id: ID!) {
  deleteComment(id: $id) {
    commentId
  }
}
""";
