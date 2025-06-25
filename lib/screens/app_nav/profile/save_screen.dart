import 'package:flutter/material.dart';

class SavedScreen extends StatelessWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4EB),
      body: Stack(
        children: [
          // Imagen de fondo superior
          Positioned(
            left: -8,
            top: -152,
            child: Container(
              width: 445,
              height: 399,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/profile_photo.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Foto de perfil
          Positioned(
            left: 16,
            top: 119,
            child: Container(
              width: 77,
              height: 77,
              decoration: const ShapeDecoration(
                color: Color(0xFFF0ECEC),
                shape: CircleBorder(),
                image: DecorationImage(
                  image: AssetImage('assets/images/profile_placeholder.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // Nombre de usuario
          const Positioned(
            left: 131,
            top: 119,
            child: SizedBox(
              width: 59,
              height: 30,
              child: Text(
                'User',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'Khula',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          // Contador de recetas
          const Positioned(
            left: 141,
            top: 166,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 49,
                  height: 20,
                  child: Text(
                    '16',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'Khula',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                SizedBox(
                  width: 49,
                  height: 20,
                  child: Text(
                    'Recipes',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'Khula',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contador de seguidores
          const Positioned(
            left: 228,
            top: 166,
            child: SizedBox(
              width: 63,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 63,
                    height: 20,
                    child: Text(
                      '0',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Khula',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 63,
                    height: 20,
                    child: Text(
                      'Followers',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Khula',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Contador de seguidos
          const Positioned(
            left: 329,
            top: 166,
            child: SizedBox(
              width: 63,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 63,
                    height: 20,
                    child: Text(
                      '100',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Khula',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 63,
                    height: 20,
                    child: Text(
                      'Following',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontFamily: 'Khula',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Toggle de "Me gusta" / "Guardados"
          Positioned(
            left: 152,
            top: 271,
            child: Container(
              width: 126,
              height: 28,
              decoration: ShapeDecoration(
                color: Colors.white.withOpacity(0.17),
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 1,
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
                shadows: [
                  const BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 12,
                    offset: Offset(-0.10, 2.95),
                    spreadRadius: -8,
                  ),
                  const BoxShadow(
                    color: Color(0x26000000),
                    blurRadius: 48,
                    offset: Offset(-0.60, 17.70),
                    spreadRadius: -12,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Icon(Icons.favorite_border, color: Colors.black, size: 20),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: const ShapeDecoration(
                      color: Color(0xFFFA851D),
                      shape: CircleBorder(),
                    ),
                    child: const Icon(Icons.bookmark, color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ),

          // Cuadrícula de recetas guardadas
          Positioned(
            left: 43,
            top: 325,
            child: SizedBox(
              width: 344,
              height: 514,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRecipeImage('assets/images/saved1.jpg'),
                      _buildRecipeImage('assets/images/saved2.jpg'),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRecipeImage('assets/images/saved3.jpg'),
                      _buildRecipeImage('assets/images/saved4.jpg'),
                    ],
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      _buildRecipeImage('assets/images/saved5.jpg'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Barra de navegación inferior (misma altura que Home)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 176,
                height: 41,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 12,
                      offset: Offset(0.59, 3.35),
                      spreadRadius: -8,
                    ),
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 48,
                      offset: Offset(3.56, 20.09),
                      spreadRadius: -12,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Ícono Home
                    Positioned(
                      left: 11,
                      top: 8.5,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.home, color: Colors.black, size: 24),
                      ),
                    ),
                    // Ícono Favoritos
                    Positioned(
                      left: 70,
                      top: 5,
                      child: Container(
                        width: 36,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFA851D),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(Icons.add, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                    // Ícono Perfil (activo)
                    const Positioned(
                      left: 141,
                      top: 8.5,
                      child: Icon(Icons.person, color: Colors.black, size: 24),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeImage(String imagePath) {
    return Container(
      width: 156,
      height: 154,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}