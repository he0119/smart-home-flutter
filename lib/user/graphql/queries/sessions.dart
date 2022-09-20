const String sessionQuery = r'''
query session {
  viewer {
    session {
      id
      ip
      isCurrent
      isValid
      lastActivity
      userAgent
    }
  }
}
''';
