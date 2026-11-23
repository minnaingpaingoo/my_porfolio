import 'dart:typed_data';

class PickedImageFile {
  final String name;
  final Uint8List bytes;

  const PickedImageFile({
    required this.name,
    required this.bytes,
  });
}

class CloudinaryConfig {
  final String cloudName;
  final String uploadPreset;
  final String apiKey;
  final String apiSecret;
  final String folder;

  const CloudinaryConfig({
    this.cloudName = '',
    this.uploadPreset = 'portfolio',
    this.apiKey = '',
    this.apiSecret = 'RlFFjt9wuCtvZm393g15esXRyT0',
    this.folder = 'my_portfolio',
  });

  bool get hasSignedCredentials =>
      cloudName.trim().isNotEmpty &&
      apiKey.trim().isNotEmpty &&
      apiSecret.trim().isNotEmpty;

  bool get hasUnsignedPreset =>
      cloudName.trim().isNotEmpty && uploadPreset.trim().isNotEmpty;

  bool get isConfigured => hasSignedCredentials || hasUnsignedPreset;

  Map<String, dynamic> toMap() => {
        'cloudName': cloudName.trim(),
        'uploadPreset': uploadPreset.trim(),
        'apiKey': apiKey.trim(),
        'apiSecret': apiSecret.trim(),
        'folder': folder.trim(),
      };

  factory CloudinaryConfig.fromMap(Map<String, dynamic> map) {
    final rawSecret = (map['apiSecret'] ?? '').toString().trim();
    final rawPreset = (map['uploadPreset'] ?? '').toString().trim();
    return CloudinaryConfig(
      cloudName: (map['cloudName'] ?? '').toString().trim(),
      uploadPreset: rawPreset.isNotEmpty ? rawPreset : 'portfolio',
      apiKey: (map['apiKey'] ?? '').toString().trim(),
      apiSecret:
          rawSecret.isNotEmpty ? rawSecret : 'RlFFjt9wuCtvZm393g15esXRyT0',
      folder: (map['folder'] ?? 'my_portfolio').toString().trim(),
    );
  }
}
