import 'package:flutter/material.dart';
import '../../../api/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _sending = false;
  String? _errorText;

  Future<void> _sendCode() async {
    setState(() {
      _sending = true;
      _errorText = null;
    });

    try {
      // Llamada real a la API
      final response = await ApiService.requestPasswordReset(_emailController.text);

      if (response['success']) {
        // Si la solicitud es exitosa, muestra un mensaje y navega
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Código enviado a tu email')),
        );

        Navigator.pushNamed(
          context,
          '/verify_code',
          arguments: {'email': _emailController.text},
        );
      } else {
        // Si hay un error en la respuesta
        setState(() {
          _errorText = response['message'] ?? 'Error al enviar el código';
        });
      }
    } catch (e) {
      // Si hay un error de conexión
      setState(() {
        _errorText = 'Error de conexión. Intenta nuevamente.';
      });
    } finally {
      setState(() {
        _sending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4EB),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              // Logo y título
              Positioned(
                left: 16,
                top: 80,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
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
                  ],
                ),
              ),

              // Título de la pantalla
              Positioned(
                left: 16,
                top: 235,
                child: SizedBox(
                  width: 265,
                  height: 28,
                  child: Text(
                    'Restablecer contraseña',
                    style: TextStyle(
                      color: Color(0xFF1E1E1E),
                      fontSize: 24,
                      fontFamily: 'Khula',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // Texto de instrucción
              Positioned(
                left: 80,
                top: 356,
                child: SizedBox(
                  width: 300,
                  child: Text(
                    'Ingrese su correo electrónico:',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'Khula',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),

              // Campo de email funcional
              Positioned(
                left: 64,
                top: 419,
                child: SizedBox(
                  width: 302,
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Khula',
                        fontWeight: FontWeight.w400,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle: const TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
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
                          return 'Ingrese su email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Ingrese un email válido';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              // Botón Enviar
              Positioned(
                left: 120,
                top: 561,
                child: SizedBox(
                  width: 180,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _sending
                        ? null
                        : () {
                      if (_formKey.currentState!.validate()) {
                        _sendCode();
                      }
                    },
                    child: _sending
                        ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFA851D)),
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Enviar',
                          style: TextStyle(
                            color: Color(0xFFFA851D),
                            fontSize: 32,
                            fontFamily: 'Khula',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Color(0xFFFA851D), size: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}