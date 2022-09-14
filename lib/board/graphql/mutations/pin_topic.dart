const String pinTopicMutation = r'''
mutation pinTopic($input: PinTopicInput!) {
  pinTopic(input: $input) {
    ... on Topic {
      id
      isPin
      editedAt
    }
  }
}
''';
