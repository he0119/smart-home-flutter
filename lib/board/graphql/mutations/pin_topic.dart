const String pinTopicMutation = r'''
mutation pinTopic($input: PinTopicInput!) {
  pinTopic(input: $input) {
    ... on Topic {
      id
      isPinned
      editedAt
    }
  }
}
''';
