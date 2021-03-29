const String setDeviceMutation = r'''
mutation setDevice($input: SetDeviceMutationInput!) {
  setDevice(input: $input) {
    device {
      id
      name
    }
  }
}
''';
