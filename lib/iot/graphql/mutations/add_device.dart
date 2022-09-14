const String addDeviceMutation = r'''
mutation addDevice($input: AddDeviceInput!) {
  addDevice(input: $input) {
    ... on Device {
      id
      name
      location
      isOnline
      createdAt
      editedAt
    }
  }
}
''';
