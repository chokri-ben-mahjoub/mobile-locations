# Build + déploie LocaTrack sur Firebase Hosting (locatrack-app.web.app
# et sakania.web.app — voir firebase.json).
#
# Usage : powershell -ExecutionPolicy Bypass -File scripts/deploy_web.ps1

flutter build web --release
firebase deploy --only hosting
