const String updateMiPushMutation = r"""
mutation updateMiPush($input: updateMiPushInput!) {
  updateMiPush(input: $input) {
    miPush {
      regId
    }
  }
}
""";
