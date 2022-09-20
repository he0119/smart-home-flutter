const String deleteSessionMutation = r'''
mutation deleteSession($input: DeleteSessionInput!) {
  deleteSession(input: $input) {
    ... on Session {
      id
    }
  }
}
''';
