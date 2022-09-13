const String updateTopicMutation = r'''
mutation updateTopic($input: UpdateTopicInput!) {
  updateTopic(input: $input) {
    ... on Topic {
      id
      title
      description
      editedAt
    }
  }
}
''';
