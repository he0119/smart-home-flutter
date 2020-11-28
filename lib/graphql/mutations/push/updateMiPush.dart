const String updateMiPushMutation = r"""
mutation updateMiPush($input: UpdateMiPushInput!) {
  updateMiPush(input: $input) {
    miPush {
      regId
    }
  }
}
""";
