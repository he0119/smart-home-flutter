const String reopenTopicMutation = r"""
mutation reopenTopic($input: ReopenTopicInput!) {
  reopenTopic(input: $input) {
    topic {
      id
      isOpen
      dateModified
    }
  }
}
""";
