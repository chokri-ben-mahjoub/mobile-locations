/// Une date sans heure (ex: date de début/fin de contrat) : exportée en
/// vraie date Excel au format jour/mois/année, contrairement à un
/// [DateTime] qui garde l'heure.
class DateOnly {
  final DateTime date;
  const DateOnly(this.date);
}

/// Un tableau à exporter : une feuille Excel, une section PDF, un fichier
/// CSV ou une image.
///
/// Les cellules de [rows] peuvent être des `String` (les noms arabes des
/// locataires n'ont besoin d'aucun traitement spécial ici — c'est au
/// moment de l'encodage, par format, que l'arabe est géré), des nombres
/// (`num`), des `DateTime`, des [DateOnly] ou `null` (cellule vide).
class ExportTable {
  /// Nom de la feuille Excel (31 caractères max), titre de la section PDF
  /// ou de l'image.
  final String name;
  final List<String> headers;
  final List<List<Object?>> rows;

  const ExportTable({required this.name, required this.headers, required this.rows});

  bool get isEmpty => rows.isEmpty;
}
