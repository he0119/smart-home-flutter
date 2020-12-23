const String updateTopicMutation = r"""
mutation updateTopic($input: UpdateTopicMutationInput!) {
  updateTopic(input: $input) {
    topic {
      id
      title
      description
      editedAt
    }
  }
}
""";
