const String addTopicMutation = r"""
mutation addTopic($input: AddTopicInput!) {
  addTopic(input: $input) {
    topic {
      id
      title
      description
      isOpen
      user {
        username
      }
      dateCreated
      dateModified
    }
  }
}
""";
