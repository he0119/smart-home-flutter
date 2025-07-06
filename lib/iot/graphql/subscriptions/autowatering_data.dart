const String autowateringDataSubscription = r'''
subscription autowateringData($deviceId: ID!) {
  autowateringData(deviceId: $deviceId) {
    id
    device {
      id
      name
      editedAt
      isOnline
      onlineAt
      offlineAt
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
''';
