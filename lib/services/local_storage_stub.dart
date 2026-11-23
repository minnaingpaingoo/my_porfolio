final Map<String, String> _memoryStorage = <String, String>{};

String? readDeviceLocalValue(String key) {
  return _memoryStorage[key];
}

void writeDeviceLocalValue(String key, String? value) {
  if (value == null || value.isEmpty) {
    _memoryStorage.remove(key);
  } else {
    _memoryStorage[key] = value;
  }
}
