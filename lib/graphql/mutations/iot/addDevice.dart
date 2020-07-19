const String addDeviceMutation = r"""
mutation addDevice($input: AddDeviceInput!) {
  addDevice(input: $input) {
    device {
      __typename
      id
      name
      location
      isOnline
      dateCreated
      dateUpdated
    }
  }
}
""";
