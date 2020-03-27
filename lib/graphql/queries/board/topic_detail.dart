const String topicDetailQuery = r"""
query topicDetail($topicId: ID!, $number: Int) {
  topic(id: $topicId) {
    __typename
    id
    title
    description
    isOpen
    user {
      username
    }
    dateCreated
    dateModified
  }
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
