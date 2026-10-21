import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Fichier généré en mémoire, à partager via le volet natif (WhatsApp,
/// e-mail, Drive, Fichiers...).
class ShareableFile {
  final String name;
  final String mimeType;
  final List<int> bytes;
  const ShareableFile(this.name, this.mimeType, this.bytes);
}

Future<ShareResult> shareFiles(List<ShareableFile> files, {String? subject}) async {
  final xFiles = <XFile>[];
  if (kIsWeb) {
    for (final f in files) {
      xFiles.add(XFile.fromData(Uint8List.fromList(f.bytes), name: f.name, mimeType: f.mimeType));
    }
  } else {
    final dir = await getTemporaryDirectory();
    for (final f in files) {
      final path = '${dir.path}/${f.name}';
      await File(path).writeAsBytes(f.bytes, flush: true);
      xFiles.add(XFile(path, mimeType: f.mimeType));
    }
  }
  return Share.shareXFiles(xFiles, subject: subject);
}
