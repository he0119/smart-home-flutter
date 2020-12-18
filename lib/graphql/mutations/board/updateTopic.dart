const String updateTopicMutation = r"""
mutation updateTopic($input: UpdateTopicInput!) {
  updateTopic(input: $input) {
    topic {
      id
      title
      description
      dateModified
    }
  }
}
""";
