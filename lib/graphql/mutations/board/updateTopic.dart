const String updateTopicMutation = r"""
mutation updateTopic($input: UpdateTopicInput!) {
  updateTopic(input: $input) {
    topic {
      __typename
      id
      title
      description
      dateModified
    }
  }
}
""";
