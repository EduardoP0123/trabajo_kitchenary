// Agrega estos métodos a tu clase ApiService existente
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://10.0.39.41:3000/api/';

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  // Solicitar el código de restablecimiento
  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    final response = await post('reset-password/request', {
      'correo': email,
    });

    return jsonDecode(response.body);
  }

  // Verificar el código ingresado
  static Future<Map<String, dynamic>> verifyResetCode(String email, String code) async {
    final response = await post('reset-password/verify', {
      'correo': email,
      'codigo': code,
    });

    return jsonDecode(response.body);
  }

  // Actualizar la contraseña
  static Future<Map<String, dynamic>> resetPassword(int userId, String newPassword) async {
    final response = await post('reset-password/update', {
      'userId': userId,
      'nuevaContraseña': newPassword,
    });

    return jsonDecode(response.body);
  }
}