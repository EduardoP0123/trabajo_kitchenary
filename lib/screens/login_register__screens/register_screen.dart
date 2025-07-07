import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../app_nav/home_screen.dart';
import 'login_screen.dart';
import '../../api/login_register_db/register_db.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  Future<void> _register() async {
    final nombreUsuario = usernameController.text.trim();
    final correo = emailController.text.trim();
    final contrasena = passwordController.text.trim();
    final confirmar = confirmPasswordController.text.trim();

    if (nombreUsuario.isEmpty || correo.isEmpty || contrasena.isEmpty || confirmar.isEmpty) {
      EasyLoading.showError('Completa todos los campos');
      return;
    }
    if (contrasena != confirmar) {
      EasyLoading.showError('Las contraseñas no coinciden');
      return;
    }

    EasyLoading.show(status: 'Registrando...');
    final success = await register(nombreUsuario, correo, contrasena);
    EasyLoading.dismiss();

    if (success) {
      EasyLoading.showSuccess('Registro exitoso');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else {
      EasyLoading.showError('El correo ya está registrado');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4EB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
            ),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 300,
                  margin: const EdgeInsets.only(top: 0),
                  decoration: BoxDecoration(
                    image: const DecorationImage(
                      image: AssetImage('assets/images/register_img.jpg'),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Crear Cuenta',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 36,
                    fontFamily: 'Fira Code',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 45,
                        child: TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            hintText: 'Nombre de Usuario',
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
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        height: 45,
                        child: TextField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
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
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
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
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
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
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 91),
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFA851D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: _register,
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
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 119),
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
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        Navigator.pushReplacement(
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
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}