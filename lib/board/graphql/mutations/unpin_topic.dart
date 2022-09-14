const String unpinTopicMutation = r'''
mutation unpinTopic($input: UnpinTopicInput!) {
  unpinTopic(input: $input) {
    ... on Topic {
      id
      isPin
      editedAt
    }
  }
}
''';
