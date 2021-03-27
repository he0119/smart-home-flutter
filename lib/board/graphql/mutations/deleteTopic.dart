const String deleteTopicMutation = r"""
mutation deleteTopic($input: DeleteTopicMutationInput!) {
  deleteTopic(input: $input) {
    clientMutationId
  }
}
""";
