const String deleteDeviceMutation = r'''
mutation deleteDevice($input: DeleteDeviceInput!) {
  deleteDevice(input: $input) {
    ... on Device {
      id
    }
  }
}
''';
