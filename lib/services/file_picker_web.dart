// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:my_porfolio/services/picked_image_file.dart';

Future<PickedImageFile?> pickLocalImageFile() async {
  final completer = Completer<PickedImageFile?>();
  final input = html.FileUploadInputElement()
    ..accept = 'image/*'
    ..style.display = 'none';

  // Attach to document.body so browsers reliably trigger the file dialog
  // inside Flutter modal overlays and don't garbage-collect the element.
  html.document.body?.append(input);

  void cleanup() {
    Future.delayed(const Duration(milliseconds: 300), () {
      input.remove();
    });
  }

  input.onChange.listen((event) {
    final files = input.files;
    if (files == null || files.isEmpty) {
      if (!completer.isCompleted) completer.complete(null);
      cleanup();
      return;
    }
    final file = files.first;
    final reader = html.FileReader();

    reader.onLoadEnd.listen((_) {
      final result = reader.result;
      if (result is ByteBuffer) {
        if (!completer.isCompleted) {
          completer.complete(
            PickedImageFile(
              name: file.name,
              bytes: result.asUint8List(),
            ),
          );
        }
      } else if (result is Uint8List) {
        if (!completer.isCompleted) {
          completer.complete(
            PickedImageFile(
              name: file.name,
              bytes: result,
            ),
          );
        }
      } else {
        if (!completer.isCompleted) completer.complete(null);
      }
      cleanup();
    });

    reader.onError.listen((_) {
      if (!completer.isCompleted) completer.complete(null);
      cleanup();
    });

    reader.readAsArrayBuffer(file);
  });

  input.click();
  return completer.future;
}
