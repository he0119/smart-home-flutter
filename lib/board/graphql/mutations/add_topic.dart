const String addTopicMutation = r'''
mutation addTopic($input: AddTopicInput!) {
  addTopic(input: $input) {
    ... on Topic {
      id
      title
      description
      isOpen
      user {
        username
      }
      createdAt
      editedAt
    }
  }
}
''';
