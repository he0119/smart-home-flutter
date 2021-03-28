const String updateMiPushMutation = r'''
mutation updateMiPush($input: UpdateMiPushMutationInput!) {
  updateMiPush(input: $input) {
    miPush {
      regId
      deviceId
      model
    }
  }
}
''';
