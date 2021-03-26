const String reopenTopicMutation = r"""
mutation reopenTopic($input: ReopenTopicMutationInput!) {
  reopenTopic(input: $input) {
    topic {
      id
      isOpen
      editedAt
    }
  }
}
""";
