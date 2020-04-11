const String topicQuery = r"""
query topic($id: ID!) {
  topic(id: $id) {
    __typename
    id
    title
    description
    isOpen
    user {
      username
      email
    }
    dateCreated
    dateModified
  }
}
""";
