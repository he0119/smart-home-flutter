const String setDeviceMutation = r"""
mutation setDevice($input: SetDeviceInput!) {
  setDevice(input: $input) {
    device {
      id
      name
    }
  }
}
""";
