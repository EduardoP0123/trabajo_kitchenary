import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class CodigoPass extends StatefulWidget {
  const CodigoPass({super.key});

  @override
  State<CodigoPass> createState() => _CodigoPassState();
}

class _CodigoPassState extends State<CodigoPass> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _codeController = TextEditingController();
  bool _verifying = false;
  String? _errorText;

  // El email se recibirá como argumento de la ruta anterior
  late String email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener el email de los argumentos
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    email = args?['email'] ?? '';
  }

  // Método para verificar el código
  Future<void> _verifyCode() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _verifying = true;
        _errorText = null;
      });

      try {
        // Llamar a la API para verificar el código
        final response = await ApiService.verifyResetCode(
            email,
            _codeController.text
        );

        if (response['success']) {
          // Código válido, navegar a la pantalla para establecer nueva contraseña
          Navigator.pushNamed(
            context,
            '/new_password', // Ruta a tu pantalla de nueva contraseña
            arguments: {'userId': response['userId']},
          );
        } else {
          // Código inválido, mostrar error
          setState(() {
            _errorText = response['message'] ?? 'Código inválido';
          });
        }
      } catch (e) {
        setState(() {
          _errorText = 'Error de conexión. Intenta nuevamente.';
        });
      } finally {
        setState(() {
          _verifying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4EB),
      body: Stack(
        children: [
          // Logo y título
          Positioned(
            left: 16,
            top: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 235,
                  height: 50,
                  child: Text(
                    'Kitchenary\n',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 36,
                      fontFamily: 'Fira Code',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Ícono del libro (puedes cambiarlo)
                const Icon(Icons.menu_book, size: 36),
              ],
            ),
          ),

          // Título de la pantalla
          const Positioned(
            left: 16,
            top: 235,
            child: SizedBox(
              width: 350,
              height: 28,
              child: Text(
                'Verificar código',
                style: TextStyle(
                  color: Color(0xFF1E1E1E),
                  fontSize: 24,
                  fontFamily: 'Khula',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // Texto instructivo
          const Positioned(
            left: 80,
            top: 300,
            child: SizedBox(
              width: 270,
              child: Text(
                'Ingresa el código enviado a tu correo:',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontFamily: 'Khula',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          // Mostrar correo electrónico
          Positioned(
            left: 80,
            top: 330,
            child: SizedBox(
              width: 270,
              child: Text(
                email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFFFA851D),
                  fontSize: 18,
                  fontFamily: 'Khula',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Campo de código de verificación
          Positioned(
            left: 64,
            top: 390,
            child: SizedBox(
              width: 302,
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Khula',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 10,
                  ),
                  decoration: InputDecoration(
                    hintText: '000000',
                    hintStyle: const TextStyle(
                      color: Colors.black38,
                      fontSize: 24,
                      fontFamily: 'Khula',
                      fontWeight: FontWeight.w300,
                    ),
                    filled: true,
                    fillColor: const Color(0x72D9D9D9),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(width: 1),
                    ),
                    errorText: _errorText,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingresa el código';
                    }
                    if (value.length != 6) {
                      return 'El código debe tener 6 dígitos';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),

          // Botón Verificar
          Positioned(
            left: 142,
            top: 500,
            child: GestureDetector(
              onTap: _verifying ? null : _verifyCode,
              child: Row(
                children: [
                  _verifying
                      ? const SizedBox(
                    width: 35,
                    height: 35,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFA851D)),
                      strokeWidth: 3,
                    ),
                  )
                      : const Text(
                    'Verificar',
                    style: TextStyle(
                      color: Color(0xFFFA851D),
                      fontSize: 36,
                      fontFamily: 'Khula',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!_verifying) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: Color(0xFFFA851D), size: 32),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Asegúrate de tener esta clase en tu proyecto
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/';

  static Future<dynamic> verifyResetCode(String email, String code) async {
    final response = await post('reset-password/verify', {
      'correo': email,
      'codigo': code,
    });

    return jsonDecode(response.body);
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }
}