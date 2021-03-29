const String deleteDeviceMutation = r'''
mutation deleteDevice($input: DeleteDeviceMutationInput!) {
  deleteDevice(input: $input) {
    deletedId
  }
}
''';
