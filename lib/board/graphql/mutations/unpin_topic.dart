const String unpinTopicMutation = r'''
mutation unpinTopic($input: UnpinTopicInput!) {
  unpinTopic(input: $input) {
    ... on Topic {
      id
      isPinned
      editedAt
    }
  }
}
''';
