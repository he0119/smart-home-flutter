const String updateDeviceMutation = r'''
mutation updateDevice($input: UpdateDeviceInput!) {
  updateDevice(input: $input) {
    ... on Device {
      id
      name
      location
      editedAt
    }
  }
}
''';
