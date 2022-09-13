const String setDeviceMutation = r'''
mutation setDevice($input: SetDeviceInput!) {
  setDevice(input: $input) {
    ... on Device {
      id
      name
    }
  }
}
''';
