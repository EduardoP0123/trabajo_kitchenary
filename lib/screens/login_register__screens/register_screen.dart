import 'package:flutter/material.dart';

import '../app_nav/home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4EB),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            top: -95,
            child: Container(
              width: 448,
              height: 369,
              decoration: ShapeDecoration(
                image: const DecorationImage(
                  image: AssetImage('assets/images/register_img.jpg'),
                  fit: BoxFit.cover,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(83),
                ),
              ),
            ),
          ),

          // Título "Crear cuenta"
          Positioned(
            left: 81,
            top: 329,
            child: SizedBox(
              width: 267,
              height: 47,
              child: Text(
                'Crear Cuenta',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontFamily: 'Fira Code',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Campo Email
          Positioned(
            left: 70,
            top: 459,
            child: SizedBox(
              width: 290,
              height: 45,
              child: TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Email',
                  hintStyle: TextStyle(
                    color: Colors.black.withOpacity(0.58),
                    fontSize: 16,
                    fontFamily: 'Khula',
                    fontWeight: FontWeight.w300,
                  ),
                  filled: true,
                  fillColor: const Color(0x72D9D9D9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),

          // Campo Contraseña
          Positioned(
            left: 70,
            top: 523,
            child: SizedBox(
              width: 290,
              height: 45,
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  hintStyle: TextStyle(
                    color: Colors.black.withOpacity(0.58),
                    fontSize: 16,
                    fontFamily: 'Khula',
                    fontWeight: FontWeight.w300,
                  ),
                  filled: true,
                  fillColor: const Color(0x72D9D9D9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),

          // Campo Confirmar Contraseña
          Positioned(
            left: 70,
            top: 587,
            child: SizedBox(
              width: 290,
              height: 45,
              child: TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Confirmar Contraseña',
                  hintStyle: TextStyle(
                    color: Colors.black.withOpacity(0.58),
                    fontSize: 16,
                    fontFamily: 'Khula',
                    fontWeight: FontWeight.w300,
                  ),
                  filled: true,
                  fillColor: const Color(0x72D9D9D9),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),

          // Botón "Registrate"
          Positioned(
            left: 91,
            top: 726,
            child: SizedBox(
              width: 262,
              height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFA851D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Registrate',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontFamily: 'Khula',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Términos y condiciones
          Positioned(
            left: 119,
            top: 805,
            child: SizedBox(
              width: 194,
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Registrandote, estas de acuerdo con los ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Khula',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    TextSpan(
                      text: 'Terminos',
                      style: TextStyle(
                        color: Color(0xFF12372A),
                        fontSize: 12,
                        fontFamily: 'Khula',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    TextSpan(
                      text: ' y ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Khula',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    TextSpan(
                      text: 'Condiciones',
                      style: TextStyle(
                        color: Color(0xFF12372A),
                        fontSize: 12,
                        fontFamily: 'Khula',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    TextSpan(
                      text: ' de la app.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Khula',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // "Ya tienes una cuenta? Ingresa"
          Positioned(
            left: 113,
            top: 874,
            child: Row(
              children: [
                const Text(
                  'Ya tienes una cuenta? ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Khula',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Ingresa',
                    style: TextStyle(
                      color: Color(0xFF12372A),
                      fontSize: 16,
                      fontFamily: 'Khula',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
