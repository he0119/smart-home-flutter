const String deviceQuery = r"""
query device($id: ID!) {
  device(id: $id) {
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
