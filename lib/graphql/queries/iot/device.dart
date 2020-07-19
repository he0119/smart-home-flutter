const String deviceQuery = r"""
query device($id: ID!) {
  device(id: $id) {
    __typename
    id
    name
    location
    isOnline
    dateCreated
    dateUpdated
    dateOnline
    dateOffline
  }
}
""";
