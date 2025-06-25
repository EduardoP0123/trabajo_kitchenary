import '../api_service.dart';

Future<bool> register(String nombreUsuario, String correo, String contrasena) async {
  try {
    final response = await ApiService.post('register', {
      'nombre_usuario': nombreUsuario,
      'correo': correo,
      'contraseña': contrasena,
    });

    return response.statusCode == 200;
  } catch (e) {
    print('Error en registro: $e');
    return false;
  }
}