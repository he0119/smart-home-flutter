const String updateDeviceMutation = r'''
mutation updateDevice($input: UpdateDeviceMutationInput!) {
  updateDevice(input: $input) {
    device {
      id
      name
      location
      editedAt
    }
  }
}
''';
