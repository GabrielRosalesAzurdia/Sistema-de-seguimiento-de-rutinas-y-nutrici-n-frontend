# Club Fitness App — Mobile (Flutter)

App móvil (Android) del gimnasio Fitness Club (Jocotenango,
Sacatepéquez). Ver `CLAUDE.md` y `docs/` en la raíz del proyecto para
el contexto completo del sistema.

## Correr el proyecto

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=<url-del-backend>
```

`API_BASE_URL` decide contra qué backend habla la app
(`lib/core/api_client.dart`). Si se omite, usa por defecto
`http://10.0.2.2:8000/api` (emulador Android).

| Entorno | Comando |
|---|---|
| Emulador Android (default) | `flutter run` |
| Simulador iOS / macOS | `flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000/api` |
| Dispositivo físico (misma red) | `flutter run --dart-define=API_BASE_URL=http://<ip-local-de-tu-máquina>:8000/api` |
| Producción (Render) | `flutter run --dart-define=API_BASE_URL=https://<app>.onrender.com/api` |

## Recursos de Flutter

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)
