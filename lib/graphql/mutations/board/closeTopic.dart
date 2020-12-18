const String closeTopicMutation = r"""
mutation closeTopic($input: CloseTopicInput!) {
  closeTopic(input: $input) {
    topic {
      id
      isOpen
      dateModified
    }
  }
}
""";
