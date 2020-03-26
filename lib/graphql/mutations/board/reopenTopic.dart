const String reopenTopicMutation = r"""
mutation reopenTopic($input: ReopenTopicInput!) {
  reopenTopic(input: $input) {
    topic {
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
  }
}
""";
