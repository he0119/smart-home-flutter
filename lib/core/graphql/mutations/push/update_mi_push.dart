const String updateMiPushMutation = r'''
mutation updateMiPush($input: UpdateMiPushInput!) {
  updateMiPush(input: $input) {
    ... on MiPush {
      regId
      deviceId
      model
    }
  }
}
''';
