# Build + déploie LocaTrack sur Firebase Hosting (locatrack-app.web.app).
#
# IMPORTANT : --dart-define=use_arabic=true est obligatoire (voir
# build_release.ps1 / lib/core/export/pdf_table_exporter.dart) — sans ce
# flag, les noms de locataires arabes peuvent s'afficher déformés dans le
# PDF exporté, y compris sur le web.
#
# Usage : powershell -ExecutionPolicy Bypass -File scripts/deploy_web.ps1

flutter build web --release --dart-define=use_arabic=true
firebase deploy --only hosting
