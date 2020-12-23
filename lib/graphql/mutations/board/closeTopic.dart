const String closeTopicMutation = r"""
mutation closeTopic($input: CloseTopicMutationInput!) {
  closeTopic(input: $input) {
    topic {
      id
      isOpen
      editedAt
    }
  }
}
""";
