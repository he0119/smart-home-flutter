const String deviceDataQuery = r"""
query deviceData($deviceId: ID!, $number: Int) {
  deviceData(deviceId: $deviceId, number: $number) {
    __typename
    id
    device {
      id
      name
      dateUpdated
      isOnline
      dateOnline
      dateOffline
    }
    time
    temperature
    humidity
    wifiSignal
    valve1
    valve2
    valve3
    pump
    valve1Delay
    valve2Delay
    valve3Delay
    pumpDelay
  }
}
""";
