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
    createdAt
    editedAt
  }
  comments(topic: $topicId, level: 0) {
    edges {
      node {
        id
        body
        user {
          username
          email
        }
        createdAt
        editedAt
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
