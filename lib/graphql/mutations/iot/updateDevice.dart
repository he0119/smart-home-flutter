const String updateDeviceMutation = r"""
mutation updateDevice($input: UpdateDeviceInput!) {
  updateDevice(input: $input) {
    device {
      __typename
      id
      name
      location
      dateUpdated
    }
  }
}
""";
