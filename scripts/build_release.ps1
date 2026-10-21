# Build APK de release pour LocaTrack.
#
# IMPORTANT : --dart-define=use_arabic=true est obligatoire. C'est un flag
# interne au package `pdf` (lib/src/pdf/options.dart) qui active le
# "shaping" correct des lettres arabes (jointure des lettres) dans les
# PDF générés par l'export (voir lib/core/export/pdf_table_exporter.dart).
# Sans ce flag, les noms de locataires arabes peuvent s'afficher déformés
# ou incomplets dans le PDF exporté — ce point a déjà causé un bug en
# production, ne jamais l'oublier.
#
# Usage : powershell -ExecutionPolicy Bypass -File scripts/build_release.ps1

flutter build apk --release --dart-define=use_arabic=true
