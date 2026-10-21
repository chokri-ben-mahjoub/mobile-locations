final _arabicPattern = RegExp(r'[؀-ۿݐ-ݿࢠ-ࣿﭐ-﷿ﹰ-﻿]');

/// Détecte si un texte contient des caractères arabes (ex: nom de
/// locataire) — utile pour aligner et orienter le texte de droite à
/// gauche plutôt que d'utiliser l'alignement latin par défaut (gauche),
/// qui tronque et aligne mal les noms arabes.
bool isArabicText(String text) => _arabicPattern.hasMatch(text);
