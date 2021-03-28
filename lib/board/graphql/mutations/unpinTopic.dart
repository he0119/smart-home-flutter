const String unpinTopicMutation = r'''
mutation unpinTopic($input: UnpinTopicMutationInput!) {
  unpinTopic(input: $input) {
    topic {
      id
      isPin
      editedAt
    }
  }
}
''';
