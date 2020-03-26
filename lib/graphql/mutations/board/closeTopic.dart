const String closeTopicMutation = r"""
mutation closeTopic($input: CloseTopicInput!) {
  closeTopic(input: $input) {
    topic {
      __typename
      id
      isOpen
      dateModified
    }
  }
}
""";
