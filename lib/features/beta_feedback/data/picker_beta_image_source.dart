import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:pantas/features/beta_feedback/data/beta_drops_stub.dart'
    if (dart.library.js_interop) 'package:pantas/features/beta_feedback/data/beta_drops_web.dart';
import 'package:pantas/features/beta_feedback/domain/beta_feedback_models.dart';

/// Opens the system picker for up to `max` files. Empty when canceled.
typedef PickFiles = Future<List<XFile>> Function(int max);

/// Screenshots from the system picker everywhere, and on web also from files
/// dropped on or pasted into the page.
class PickerBetaImageSource implements BetaImageSource {
  PickerBetaImageSource({
    PickFiles pickFiles = _pickWithPlugin,
    Stream<List<PickedImage>> Function() drops = webDropsAndPastes,
  })  : _pickFiles = pickFiles,
        _drops = drops;

  final PickFiles _pickFiles;
  final Stream<List<PickedImage>> Function() _drops;

  @override
  Future<List<PickedImage>> pick({required int max}) async {
    if (max <= 0) return const [];
    final files = await _pickFiles(max);
    return [
      // Some platforms ignore the limit, so cut here too.
      for (final file in files.take(max))
        PickedImage(
          bytes: await file.readAsBytes(),
          contentType: _contentType(file),
          name: file.name,
        ),
    ];
  }

  @override
  Stream<List<PickedImage>> dropsAndPastes() => _drops();
}

/// The picker rejects a limit below 2, so one image uses the single picker.
Future<List<XFile>> _pickWithPlugin(int max) async {
  final picker = ImagePicker();
  if (max == 1) {
    final one = await picker.pickImage(source: ImageSource.gallery);
    return [if (one != null) one];
  }
  return picker.pickMultiImage(limit: max);
}

/// The type the platform reports, or the one the file name implies. A type
/// nobody can name stays unrecognized, so the caller refuses it.
String _contentType(XFile file) {
  final reported = file.mimeType?.toLowerCase();
  if (reported != null && reported.isNotEmpty) {
    return reported == 'image/jpg' ? 'image/jpeg' : reported;
  }
  final name = file.name.toLowerCase();
  if (name.endsWith('.png')) return 'image/png';
  if (name.endsWith('.jpg') || name.endsWith('.jpeg')) return 'image/jpeg';
  if (name.endsWith('.webp')) return 'image/webp';
  return 'application/octet-stream';
}
