const String updateDeviceMutation = r"""
mutation updateDevice($input: UpdateDeviceInput!) {
  updateDevice(input: $input) {
    device {
      id
      name
      location
      dateUpdated
    }
  }
}
""";
