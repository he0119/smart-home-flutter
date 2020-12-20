const String deviceDataQuery = r"""
query autowateringData {
  autowateringData(last: 1) {
    edges {
      node {
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
  }
}
""";
