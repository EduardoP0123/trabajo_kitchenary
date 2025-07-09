import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ApiService {
  static const String baseUrl = 'http://10.0.40.104:3000/api/';

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

  // ============ MÉTODOS PARA GESTIÓN DE RECETAS ============

  // Comprimir imagen
  static Future<File> _compressImage(File file) async {
    // Obtener información del archivo
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(dir.path, '${DateTime.now().millisecondsSinceEpoch}.jpg');

    // Comprimir la imagen
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70, // Calidad de compresión
      format: CompressFormat.jpeg,
    );

    return File(result!.path);
  }

  // Guardar receta usando multipart/form-data (más confiable que base64)
  static Future<Map<String, dynamic>> saveRecipe({
    required String titulo,
    required String descripcion,
    required File imagen,
    required int tiempoPreparacion,
    required String pasos,
    required int idCategoria,
    required int idUsuario, // Nuevo parámetro requerido
  }) async {
    try {
      // Comprimir la imagen antes de enviarla
      File imagenComprimida = await _compressImage(imagen);

      print('Imagen original: ${await imagen.length()} bytes');
      print('Imagen comprimida: ${await imagenComprimida.length()} bytes');
      print('Enviando receta con id_usuario: $idUsuario');

      // Crear una petición multipart
      var request = http.MultipartRequest(
          'POST',
          Uri.parse('${baseUrl}recetas')
      );

      // Agregar los campos de texto
      request.fields['titulo'] = titulo;
      request.fields['descripcion'] = descripcion;
      request.fields['tiempo_preparacion'] = tiempoPreparacion.toString();
      request.fields['pasos'] = pasos;
      request.fields['id_categoria'] = idCategoria.toString();
      request.fields['id_usuario'] = idUsuario.toString(); // Enviar el ID del usuario

      // Adjuntar la imagen como archivo
      request.files.add(await http.MultipartFile.fromPath(
          'imagen',
          imagenComprimida.path
      ));

      print('Enviando solicitud a: ${baseUrl}recetas');

      // Enviar la solicitud
      var streamedResponse = await request.send();

      // Convertir la respuesta a http.Response
      final response = await http.Response.fromStream(streamedResponse);
      print('Código de estado HTTP: ${response.statusCode}');
      print('Respuesta: ${response.body}');

      if (response.statusCode != 200) {
        if (response.body.contains('<!DOCTYPE') || response.body.contains('<html')) {
          return {
            'success': false,
            'message': 'El servidor respondió con HTML en lugar de JSON. Código: ${response.statusCode}'
          };
        }
      }

      // Intentar parsear la respuesta JSON
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': 'Error al interpretar la respuesta: $e'
        };
      }
    } catch (e) {
      print('Error en saveRecipe: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Versión alternativa usando base64 como respaldo
  static Future<Map<String, dynamic>> saveRecipeBase64({
    required String titulo,
    required String descripcion,
    required File imagen,
    required int tiempoPreparacion,
    required String pasos,
    required int idCategoria,
    required int idUsuario, // Nuevo parámetro requerido
  }) async {
    try {
      // Comprimir la imagen antes de convertirla a base64
      File imagenComprimida = await _compressImage(imagen);

      // Convertir imagen a base64
      List<int> imageBytes = await imagenComprimida.readAsBytes();
      String base64Image = base64Encode(imageBytes);

      print('Enviando solicitud a: ${baseUrl}recetas-base64');
      print('Tamaño de imagen en base64: ${base64Image.length} caracteres');
      print('Enviando receta con id_usuario: $idUsuario');

      final response = await post('recetas-base64', {
        'titulo': titulo,
        'descripcion': descripcion,
        'imagen_base64': base64Image,
        'tiempo_preparacion': tiempoPreparacion,
        'pasos': pasos,
        'id_categoria': idCategoria,
        'id_usuario': idUsuario, // Enviar el ID del usuario
      });

      // Verificar primero si la respuesta es HTML en lugar de JSON
      final String body = response.body;
      print('Código de estado HTTP: ${response.statusCode}');

      if (body.trim().startsWith('<!DOCTYPE') || body.contains('<html')) {
        print('ERROR: Respuesta HTML recibida en lugar de JSON');
        return {'success': false, 'message': 'El servidor respondió con HTML en lugar de JSON'};
      }

      // Si llegamos aquí, asumimos que es JSON válido
      return jsonDecode(body);
    } catch (e) {
      print('Error en saveRecipeBase64: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // Obtener todas las recetas
  static Future<Map<String, dynamic>> getAllRecipes() async {
    try {
      final response = await get('recetas');
      return jsonDecode(response.body);
    } catch (e) {
      print('Error en getAllRecipes: $e');
      return {'success': false, 'message': 'Error: $e', 'recetas': []};
    }
  }

  // Obtener una receta por su ID
  static Future<Map<String, dynamic>> getRecipeById(int recipeId) async {
    try {
      final response = await get('recetas/$recipeId');
      return jsonDecode(response.body);
    } catch (e) {
      print('Error en getRecipeById: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}