import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import '../utils/id_generator.dart';

class AttachmentService {
  final AppDatabase db;
  final ImagePicker _picker = ImagePicker();

  AttachmentService(this.db);

  /// Ouvre la caméra ou la galerie, copie l'image dans le dossier de l'app
  /// et enregistre la pièce jointe pour ce contrat. Retourne false si
  /// l'utilisateur a annulé.
  Future<bool> captureAndSave({
    required String contractId,
    required String category,
    required ImageSource source,
  }) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked == null) return false;

    final dir = await getApplicationDocumentsDirectory();
    final attachmentsDir = Directory('${dir.path}/attachments/$contractId');
    if (!await attachmentsDir.exists()) {
      await attachmentsDir.create(recursive: true);
    }

    final id = newId();
    final ext = picked.path.split('.').last;
    final destPath = '${attachmentsDir.path}/$id.$ext';
    await File(picked.path).copy(destPath);

    await db.addAttachment(contractId: contractId, category: category, filePath: destPath);
    return true;
  }

  Future<void> delete(Attachment attachment) async {
    await db.deleteAttachment(attachment.id);
    final file = File(attachment.filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}

const Map<String, String> attachmentCategoryLabels = {
  'contrat': 'Contrat signé',
  'cin': 'CIN locataire',
  'etat_lieux': 'État des lieux',
  'autre': 'Autre',
};
