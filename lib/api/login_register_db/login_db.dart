import 'dart:convert';
import '../api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> login(String correo, String contrasena) async {
  try {
    final response = await ApiService.post('login', {
      'correo': correo,
      'contraseña': contrasena,
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      // Guardar el ID del usuario y otros datos
      final usuario = data['usuario'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', usuario['id_usuario']);
      await prefs.setString('userEmail', correo);

      print('Login exitoso, ID: ${usuario['id_usuario']}');
      return data; // Incluye {success: true, usuario: {id_usuario: X, ...}}
    } else {
      print('Error de login: ${response.body}');
      return {'success': false, 'message': data['message'] ?? 'Error desconocido'};
    }
  } catch (e) {
    print('Error de conexión: $e');
    return {'success': false, 'message': 'Error de conexión'};
  }
}