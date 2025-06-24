import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:proyecto_final_construccion/screens/login_register__screens/register_screen.dart';
import '../app_nav/home_screen.dart';
import '../../api/login_register_db/login_db.dart'; // Importa la función login

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login() async {
    final correo = emailController.text.trim();
    final contrasena = passwordController.text.trim();

    if (correo.isEmpty || contrasena.isEmpty) {
      EasyLoading.showError('Completa todos los campos');
      return;
    }

    EasyLoading.show(status: 'Ingresando...');
    final success = await login(correo, contrasena);
    EasyLoading.dismiss();

    if (success) {
      EasyLoading.showSuccess('Bienvenido');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      EasyLoading.showError('Credenciales incorrectas');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4EB),
      body: Stack(
        children: [
          // Fondo superior con imagen y borde redondeado
          Positioned(
            left: 0,
            top: 0,
            child: Opacity(
              opacity: 0.97,
              child: Container(
                width: size.width + 46,
                height: 272,
                decoration: const ShapeDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/login.jpg'),
                    fit: BoxFit.cover,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(150),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Título "Iniciar sesión"
          Positioned(
            left: 64,
            top: 326,
            child: SizedBox(
              width: 307,
              height: 47,
              child: Text(
                'Iniciar sesión',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 36,
                  fontFamily: 'Fira Code',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          // Campo Email (TextField)
          Positioned(
            left: 64,
            top: 475,
            child: SizedBox(
              width: 302,
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
          // Campo Contraseña (TextField)
          Positioned(
            left: 64,
            top: 560,
            child: SizedBox(
              width: 302,
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
          // Recordar (Checkbox) y Olvidaste tu contraseña? (Botón)
          Positioned(
            left: 64,
            top: 628,
            child: Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (value) {
                    setState(() {
                      rememberMe = value ?? false;
                    });
                  },
                  activeColor: const Color(0xFFFA851D),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Text(
                  'Recordar',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontFamily: 'Khula',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(width: 24),
                TextButton(
                  onPressed: () {
                    // Acción de olvidar contraseña
                  },
                  child: const Text(
                    'Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: Color(0xFF436850),
                      fontSize: 16,
                      fontFamily: 'Khula',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Botón "Ingresa"
          Positioned(
            left: 86,
            top: 725,
            child: SizedBox(
              width: 268,
              height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFA851D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: _login,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Ingresa',
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
          // Texto "No tienes una cuenta? Registrate" (Registrate es botón)
          Positioned(
            left: 75,
            top: 858,
            child: Row(
              children: [
                const Text(
                  'No tienes una cuenta? ',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontFamily: 'Khula',
                    fontWeight: FontWeight.w300,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Registrate',
                    style: TextStyle(
                      color: Color(0xFF436850),
                      fontSize: 20,
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