import 'package:flutter/material.dart';

/// Navigator key global — usado por [ApiClient] para forzar la
/// navegación de vuelta a Login cuando una sesión deja de ser válida
/// (ej. el usuario fue desactivado desde el panel), sin depender de
/// un BuildContext de pantalla (ApiClient no tiene ninguno).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
