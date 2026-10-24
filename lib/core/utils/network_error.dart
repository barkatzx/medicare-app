const String connectionErrorMessage =
    "Your connection isn't stable. Check your internet connection and try again.";

bool isConnectionError(Object error) {
  final text = error.toString().toLowerCase();
  return text.contains('socketexception') ||
      text.contains('clientexception') ||
      text.contains('connection refused') ||
      text.contains('failed host lookup') ||
      text.contains('connection reset') ||
      text.contains('connection closed') ||
      text.contains('network is unreachable') ||
      text.contains('timeoutexception') ||
      text.contains('connection timeout') ||
      text.contains('handshakeexception');
}

String friendlyErrorMessage(Object error) =>
    isConnectionError(error) ? connectionErrorMessage : error.toString();
