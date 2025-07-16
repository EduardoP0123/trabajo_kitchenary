import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ApiService {
  static const String baseUrl = 'http://10.0.42.44:3000/api/';

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url);
  }

  static Future<Map<String, dynamic>> getRecipeDetails(int recetaId) async {
    try {
      final response = await get('recetas/detalle/$recetaId');
      final result = jsonDecode(response.body);
      return result;
    } catch (e) {
      return {
        'success': false,
        'receta': null,
        'message': e.toString()
      };
    }
  }

  static Future<Map<String, dynamic>> saveRecipe({
    required String titulo,
    required String descripcion,
    required File imagen,
    required int tiempoPreparacion,
    required String pasos,
    required int idCategoria,
    required int idUsuario,
    required String ingredientes,
  }) async {
    try {
      File imagenComprimida = await _compressImage(imagen);
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}recetas'),
      );
      request.fields['titulo'] = titulo;
      request.fields['descripcion'] = descripcion;
      request.fields['tiempo_preparacion'] = tiempoPreparacion.toString();
      request.fields['pasos'] = pasos;
      request.fields['id_categoria'] = idCategoria.toString();
      request.fields['id_usuario'] = idUsuario.toString();
      request.fields['ingredientes'] = ingredientes;
      request.files.add(await http.MultipartFile.fromPath('imagen', imagenComprimida.path));
      var streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<File> _compressImage(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
      format: CompressFormat.jpeg,
    );
    return File(result!.path);
  }

  static Future<Map<String, dynamic>> getAllRecipes() async {
    try {
      final response = await get('recetas');
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e', 'recetas': []};
    }
  }

  static Future<Map<String, dynamic>> getRecipesByCategory(int categoryId) async {
    try {
      final response = await get('recetas/categoria/$categoryId');
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e', 'recetas': []};
    }
  }

  static Future<Map<String, dynamic>> getRecipesByUser(int userId) async {
    try {
      final response = await get('recetas/usuario/$userId');
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e', 'recetas': []};
    }
  }

  static Future<Map<String, dynamic>> getCategories() async {
    try {
      final response = await get('categorias');
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e', 'categorias': []};
    }
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await post('auth/login', {
        'correo': email,
        'contraseña': password,
      });
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await post('auth/register', {
        'nombre_usuario': name,
        'correo': email,
        'contraseña': password,
      });
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getComments(int recetaId) async {
    try {
      final response = await get('comentarios/$recetaId');
      final result = jsonDecode(response.body);
      return result;
    } catch (e) {
      return {'success': false, 'comentarios': [], 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> addComment(int recetaId, int userId, String texto) async {
    try {
      final response = await post('comentarios', {
        'id_receta': recetaId,
        'id_usuario': userId,
        'texto': texto,
      });
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getUserRatingForRecipe(int userId, int recetaId) async {
    try {
      final response = await get('valoraciones/usuario/$userId/receta/$recetaId');
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'valoracion': null};
    }
  }

  static Future<Map<String, dynamic>> rateRecipe(int recetaId, int userId, int rating) async {
    try {
      final response = await post('valoraciones', {
        'id_receta': recetaId,
        'id_usuario': userId,
        'valor': rating,
      });
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> checkFollowStatus(int userId, int followerId) async {
    try {
      final response = await get('seguimiento/$userId/$followerId');
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'following': false};
    }
  }

  static Future<Map<String, dynamic>> getUserInfo(int userId) async {
    try {
      final response = await get('usuarios/$userId');
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'usuario': null};
    }
  }

  static Future<Map<String, dynamic>> toggleFollow(int userId, int followerId) async {
    try {
      final response = await post('seguimiento/toggle', {
        'id_usuario': userId,
        'id_seguidor': followerId,
      });
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> requestPasswordReset(String email) async {
    try {
      final response = await post('reset-password/request', {
        'correo': email,
      });
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // MODIFICADO: Devuelve promedio y cantidad
  static Future<Map<String, dynamic>> getAverageRating(int recetaId) async {
    try {
      final response = await get('valoraciones/promedio/$recetaId');
      final data = jsonDecode(response.body);
      return {
        'promedio': (data['promedio'] ?? 0).toDouble(),
        'cantidad': (data['cantidad'] ?? 0)
      };
    } catch (e) {
      return {'promedio': 0.0, 'cantidad': 0};
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    String? nombre,
    String? correo,
    File? imagenPerfil,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${baseUrl}usuarios/actualizar'),
      );

      request.fields['id_usuario'] = userId.toString();
      if (nombre != null) request.fields['nombre_usuario'] = nombre;
      if (correo != null) request.fields['correo'] = correo;

      if (imagenPerfil != null) {
        File imagenComprimida = await _compressImage(imagenPerfil);
        request.files.add(await http.MultipartFile.fromPath(
            'imagen_perfil',
            imagenComprimida.path
        ));
      }

      var streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> searchRecipes(String query) async {
    try {
      final response = await post('recetas/buscar', {'query': query});
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e', 'recetas': []};
    }
  }

  // NUEVOS MÉTODOS PARA SEGUIDORES

  // Obtener lista de seguidores
  static Future<Map<String, dynamic>> getFollowers(int userId) async {
    try {
      final response = await get('usuarios/$userId/seguidores');
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'seguidores': [], 'message': e.toString()};
    }
  }

  // Obtener lista de usuarios seguidos
  static Future<Map<String, dynamic>> getFollowing(int userId) async {
    try {
      final response = await get('usuarios/$userId/seguidos');
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'seguidos': [], 'message': e.toString()};
    }
  }
}