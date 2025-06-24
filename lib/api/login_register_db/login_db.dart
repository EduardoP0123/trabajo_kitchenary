import 'dart:convert';
import '../api_service.dart';

Future<bool> login(String correo, String contrasena) async {
  try {
    final response = await ApiService.post('login', {
      'correo': correo,
      'contraseña': contrasena,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print('Login exitoso: $data');
      return true;
    } else {
      print('Error de login: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Error de conexión: $e');
    return false;
  }
}