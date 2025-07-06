const String deviceSubscription = r'''
subscription device($id: ID!) {
  device(id: $id) {
    id
    name
    isOnline
    onlineAt
    offlineAt
    createdAt
    deviceType
    editedAt
    location
  }
}
''';
