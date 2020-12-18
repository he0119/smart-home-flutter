const String addDeviceMutation = r"""
mutation addDevice($input: AddDeviceInput!) {
  addDevice(input: $input) {
    device {
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
