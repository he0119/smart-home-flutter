const String topicDetailQuery = r"""
query topicDetail($topicId: ID!) {
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
  comments(topic: $topicId) {
    edges {
      node {
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
  }
}
""";
