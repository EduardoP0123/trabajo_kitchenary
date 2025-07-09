import 'dart:convert';
import '../api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>> register(String nombreUsuario, String correo, String contrasena) async {
  try {
    final response = await ApiService.post('register', {
      'nombre_usuario': nombreUsuario,
      'correo': correo,
      'contraseña': contrasena,
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      // Si el registro es exitoso, hacer login para obtener el ID
      final loginResponse = await ApiService.post('login', {
        'correo': correo,
        'contraseña': contrasena,
      });

      final loginData = jsonDecode(loginResponse.body);

      if (loginResponse.statusCode == 200 && loginData['success'] == true) {
        // Guardar el ID del usuario
        final usuario = loginData['usuario'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', usuario['id_usuario']);
        await prefs.setString('userEmail', correo);

        print('Registro exitoso, ID: ${usuario['id_usuario']}');
        return loginData;
      }

      return {'success': true, 'message': 'Registro exitoso'};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Error en registro'};
    }
  } catch (e) {
    print('Error en registro: $e');
    return {'success': false, 'message': 'Error de conexión'};
  }
}