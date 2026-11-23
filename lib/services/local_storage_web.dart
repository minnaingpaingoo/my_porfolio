// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

String? readDeviceLocalValue(String key) {
  try {
    return html.window.localStorage[key];
  } catch (_) {
    return null;
  }
}

void writeDeviceLocalValue(String key, String? value) {
  try {
    if (value == null || value.isEmpty) {
      html.window.localStorage.remove(key);
    } else {
      html.window.localStorage[key] = value;
    }
  } catch (_) {}
}
