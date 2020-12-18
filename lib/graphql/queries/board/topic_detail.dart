const String topicDetailQuery = r"""
query topicDetail($topicId: ID!, $number: Int) {
  topic(id: $topicId) {
    id
    title
    description
    isOpen
    user {
      username
      email
    }
    dateCreated
    dateModified
  }
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
