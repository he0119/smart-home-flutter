const String deleteTopicMutation = r'''
mutation deleteTopic($input: DeleteTopicInput!) {
  deleteTopic(input: $input) {
    ... on Topic {
      id
    }
  }
}
''';
