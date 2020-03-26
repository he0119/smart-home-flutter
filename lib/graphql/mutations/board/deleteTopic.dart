const String deleteTopicMutation = r"""
mutation deleteTopic($id: ID!) {
  deleteTopic(id: $id) {
    topicId
  }
}
""";
