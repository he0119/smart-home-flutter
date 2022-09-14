const String deviceSubscription = r'''
subscription device {
  device {
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
