final _arabicPattern = RegExp(r'[؀-ۿݐ-ݿࢠ-ࣿﭐ-﷿ﹰ-﻿]');

/// Détecte si un texte contient des caractères arabes (ex: nom de
/// locataire) — utile pour aligner et orienter le texte de droite à
/// gauche plutôt que d'utiliser l'alignement latin par défaut (gauche),
/// qui tronque et aligne mal les noms arabes.
bool isArabicText(String text) => _arabicPattern.hasMatch(text);

const _bracketMirrors = {
  '(': ')',
  ')': '(',
  '[': ']',
  ']': '[',
  '{': '}',
  '}': '{',
};

/// Inverse les parenthèses/crochets/accolades d'un texte avant de le
/// dessiner en RTL (ex: PDF) : contrairement à un moteur de texte complet,
/// le renderer de `pdf` ne fait pas ce miroir automatiquement, donc une
/// parenthèse ouvrante dessinée telle quelle finit visuellement du mauvais
/// côté dans un nom comme "عبدالرحمن بن صالح (الجمعية)".
String mirrorBracketsForRtl(String text) =>
    text.split('').map((c) => _bracketMirrors[c] ?? c).join();
