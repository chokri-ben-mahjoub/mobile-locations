import 'package:flutter/material.dart';

/// Limite la largeur du contenu sur grand écran (desktop/web), centré —
/// même largeur max que la coquille de navigation principale
/// ([ScaffoldWithNav]). Sans ça, les écrans poussés par-dessus la
/// navigation (détail de contrat, formulaire, historique...) s'étirent
/// sur toute la largeur de la fenêtre au lieu de rester lisibles.
class WebContentConstraint extends StatelessWidget {
  const WebContentConstraint({super.key, required this.child, this.maxWidth = 1080});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
