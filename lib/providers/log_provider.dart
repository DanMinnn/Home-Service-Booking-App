import 'package:flutter/foundation.dart';

class LogProvider {
  final String prefix;
  const LogProvider(this.prefix);
  void log(String message) {
    if (kReleaseMode) {
      return;
    }
    print('$prefix $message');
  }
}
