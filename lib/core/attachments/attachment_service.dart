import 'dart:convert';

import 'package:image_picker/image_picker.dart';

import '../data/firestore_service.dart';
import '../data/models.dart';

class AttachmentService {
  final FirestoreService service;
  final ImagePicker _picker = ImagePicker();

  AttachmentService(this.service);

  /// Ouvre la caméra ou la galerie, compresse l'image et l'enregistre
  /// directement dans Firestore (encodée en base64 — pas de Firebase
  /// Storage, qui exige le forfait payant). Retourne false si
  /// l'utilisateur a annulé.
  Future<bool> captureAndSave({
    required String contractId,
    required String category,
    required ImageSource source,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 60,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (picked == null) return false;

    final bytes = await picked.readAsBytes();
    final data = base64Encode(bytes);

    await service.addAttachment(contractId: contractId, category: category, data: data);
    return true;
  }

  Future<void> delete(Attachment attachment) {
    return service.deleteAttachment(attachment.id);
  }
}

const Map<String, String> attachmentCategoryLabels = {
  'contrat': 'Contrat signé',
  'cin': 'CIN locataire',
  'etat_lieux': 'État des lieux',
  'autre': 'Autre',
};
