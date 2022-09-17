const String reopenTopicMutation = r'''
mutation reopenTopic($input: ReopenTopicInput!) {
  reopenTopic(input: $input) {
    ... on Topic {
      id
      isClosed
      editedAt
    }
  }
}
''';
