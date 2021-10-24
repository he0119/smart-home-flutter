const String pinTopicMutation = r'''
mutation pinTopic($input: PinTopicMutationInput!) {
  pinTopic(input: $input) {
    topic {
      id
      isPin
      editedAt
    }
  }
}
''';
