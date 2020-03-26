const String closeTopicMutation = r"""
mutation closeTopic($input: CloseTopicInput!) {
  closeTopic(input: $input) {
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
