import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:my_porfolio/services/file_picker_stub.dart'
    if (dart.library.html) 'package:my_porfolio/services/file_picker_web.dart';
import 'package:my_porfolio/services/picked_image_file.dart';

class CloudinaryUploadResult {
  final String? secureUrl;
  final String? errorMessage;

  const CloudinaryUploadResult({
    this.secureUrl,
    this.errorMessage,
  });

  bool get isSuccess => secureUrl != null && secureUrl!.isNotEmpty;
}

class CloudinaryService {
  /// Opens the file picker to select an image from the user's device.
  static Future<PickedImageFile?> pickImage() {
    return pickLocalImageFile();
  }

  /// Uploads a [PickedImageFile] to Cloudinary.
  /// Supports both:
  /// 1) Signed Upload (using `apiKey` + `apiSecret` with SHA-1 signature, works with
  ///    any preset or no preset at all)
  /// 2) Unsigned Upload (using `uploadPreset` when Signing Mode is set to Unsigned)
  static Future<CloudinaryUploadResult> uploadImage({
    required PickedImageFile file,
    required CloudinaryConfig config,
  }) async {
    if (!config.isConfigured) {
      return const CloudinaryUploadResult(
        errorMessage:
            'Please configure your Cloudinary Cloud Name and either an Unsigned Upload Preset or API Key + API Secret.',
      );
    }

    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/${config.cloudName.trim()}/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);
      final folder = config.folder.trim();
      final preset = config.uploadPreset.trim();

      if (config.hasSignedCredentials) {
        // Signed upload: sign parameters in alphabetical order + apiSecret
        final timestamp =
            (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
        final paramsToSign = <String, String>{
          'timestamp': timestamp,
        };
        if (folder.isNotEmpty) {
          paramsToSign['folder'] = folder;
        }
        if (preset.isNotEmpty) {
          paramsToSign['upload_preset'] = preset;
        }

        final sortedKeys = paramsToSign.keys.toList()..sort();
        final canonicalString = sortedKeys
            .map((k) => '$k=${paramsToSign[k]}')
            .join('&');
        final signature =
            _sha1Hex('$canonicalString${config.apiSecret.trim()}');

        request.fields['api_key'] = config.apiKey.trim();
        request.fields['timestamp'] = timestamp;
        request.fields['signature'] = signature;
        if (folder.isNotEmpty) {
          request.fields['folder'] = folder;
        }
        if (preset.isNotEmpty) {
          request.fields['upload_preset'] = preset;
        }
      } else {
        // Unsigned upload: only allowed when the preset's Signing Mode is Unsigned
        request.fields['upload_preset'] = preset;
        if (folder.isNotEmpty) {
          request.fields['folder'] = folder;
        }
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          file.bytes,
          filename: file.name,
        ),
      );

      final streamedResponse = await request.send();
      final responseBody = await streamedResponse.stream.bytesToString();
      final Map<String, dynamic> decoded =
          jsonDecode(responseBody) as Map<String, dynamic>;

      if (streamedResponse.statusCode >= 200 &&
          streamedResponse.statusCode < 300) {
        final secureUrl =
            (decoded['secure_url'] ?? decoded['url'] ?? '').toString().trim();
        if (secureUrl.isNotEmpty) {
          return CloudinaryUploadResult(secureUrl: secureUrl);
        }
        return const CloudinaryUploadResult(
          errorMessage: 'Upload succeeded, but no secure_url was returned.',
        );
      } else {
        final errObj = decoded['error'];
        final rawMsg = errObj is Map
            ? (errObj['message'] ?? responseBody).toString()
            : responseBody;

        if (rawMsg.toLowerCase().contains('unknown api key')) {
          return const CloudinaryUploadResult(
            errorMessage:
                'Cloudinary Error (401): Unknown API Key — Your Upload Preset is set to "Signed" in Cloudinary! Either change the preset\'s Signing Mode to "Unsigned" in Cloudinary Console, OR enter your API Key & API Secret in Cloudinary Setup.',
          );
        }

        return CloudinaryUploadResult(
          errorMessage:
              'Cloudinary Error (${streamedResponse.statusCode}): $rawMsg',
        );
      }
    } catch (e) {
      return CloudinaryUploadResult(
        errorMessage: 'Failed to upload image to Cloudinary: $e',
      );
    }
  }

  /// Pure Dart SHA-1 implementation for Cloudinary signature generation.
  static String _sha1Hex(String input) {
    final data = utf8.encode(input);
    final msgLen = data.length;
    final bitLen = msgLen * 8;

    // Padding: append 0x80, then 0x00 until length % 64 == 56, then 64-bit big-endian bitLen
    final padLen = ((56 - (msgLen + 1) % 64) + 64) % 64;
    final totalLen = msgLen + 1 + padLen + 8;
    final buf = Uint8List(totalLen);
    buf.setRange(0, msgLen, data);
    buf[msgLen] = 0x80;

    final bd = ByteData.sublistView(buf);
    bd.setUint32(totalLen - 8, (bitLen ~/ 0x100000000) & 0xffffffff, Endian.big);
    bd.setUint32(totalLen - 4, bitLen & 0xffffffff, Endian.big);

    int h0 = 0x67452301;
    int h1 = 0xEFCDAB89;
    int h2 = 0x98BADCFE;
    int h3 = 0x10325476;
    int h4 = 0xC3D2E1F0;

    final w = Uint32List(80);
    int rotl(int val, int shift) =>
        ((val << shift) & 0xffffffff) | ((val & 0xffffffff) >>> (32 - shift));

    for (int offset = 0; offset < totalLen; offset += 64) {
      for (int i = 0; i < 16; i++) {
        w[i] = bd.getUint32(offset + i * 4, Endian.big);
      }
      for (int i = 16; i < 80; i++) {
        w[i] = rotl(w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16], 1);
      }

      int a = h0;
      int b = h1;
      int c = h2;
      int d = h3;
      int e = h4;

      for (int i = 0; i < 80; i++) {
        int f;
        int k;
        if (i < 20) {
          f = (b & c) | ((~b & 0xffffffff) & d);
          k = 0x5A827999;
        } else if (i < 40) {
          f = b ^ c ^ d;
          k = 0x6ED9EBA1;
        } else if (i < 60) {
          f = (b & c) | (b & d) | (c & d);
          k = 0x8F1BBCDC;
        } else {
          f = b ^ c ^ d;
          k = 0xCA62C1D6;
        }

        final temp = (rotl(a, 5) + f + e + k + w[i]) & 0xffffffff;
        e = d;
        d = c;
        c = rotl(b, 30);
        b = a;
        a = temp;
      }

      h0 = (h0 + a) & 0xffffffff;
      h1 = (h1 + b) & 0xffffffff;
      h2 = (h2 + c) & 0xffffffff;
      h3 = (h3 + d) & 0xffffffff;
      h4 = (h4 + e) & 0xffffffff;
    }

    String hex32(int v) => v.toRadixString(16).padLeft(8, '0');
    return '${hex32(h0)}${hex32(h1)}${hex32(h2)}${hex32(h3)}${hex32(h4)}';
  }
}
