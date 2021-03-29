const String addTopicMutation = r'''
mutation addTopic($input: AddTopicMutationInput!) {
  addTopic(input: $input) {
    topic {
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
