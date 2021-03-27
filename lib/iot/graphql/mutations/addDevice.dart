const String addDeviceMutation = r"""
mutation addDevice($input: AddDeviceMutationInput!) {
  addDevice(input: $input) {
    device {
      id
      name
      location
      isOnline
      createdAt
      editedAt
    }
  }
}
""";
