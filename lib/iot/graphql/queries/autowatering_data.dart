const String deviceDataQuery = r"""
query autowateringData {
  autowateringData(first: 1, orderBy: "-time") {
    edges {
      node {
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
  }
}
""";
