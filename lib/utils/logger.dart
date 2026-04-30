import 'package:flutter/foundation.dart';

void logDebug(String message) {
  if (kDebugMode) {
    // ignore: avoid_print
    print(message);
  }
}