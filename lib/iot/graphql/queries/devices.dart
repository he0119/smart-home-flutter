const String devicesQuery = r'''
query devices {
  devices {
    edges {
      node {
        id
        name
        deviceType
        isOnline
      }
    }
  }
}
''';
