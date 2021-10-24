const String miPushQuery = r'''
query miPush($deviceId: String!) {
  miPush(deviceId: $deviceId) {
    regId
  }
}
''';
