const String deviceSubscription = r'''
subscription device($id: GlobalID!) {
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
