const String commentsQuery = r"""
query comments($topicId: ID!, $number: Int) {
  comments(topicId: $topicId, number: $number) {
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
""";