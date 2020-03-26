const String reopenTopicMutation = r"""
mutation reopenTopic($input: ReopenTopicInput!) {
  reopenTopic(input: $input) {
    topic {
      __typename
      id
      isOpen
      dateModified
    }
  }
}
""";
