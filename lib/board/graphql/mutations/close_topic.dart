const String closeTopicMutation = r'''
mutation closeTopic($input: CloseTopicInput!) {
  closeTopic(input: $input) {
    ... on Topic {
      id
      isOpen
      editedAt
    }
  }
}
''';
