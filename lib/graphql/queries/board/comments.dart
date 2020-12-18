const String commentsQuery = r"""
query comments($topicId: ID!, $number: Int) {
  comments(topicId: $topicId, number: $number) {
    id
    body
    user {
      username
      email
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
""";
