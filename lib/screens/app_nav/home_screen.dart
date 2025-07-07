import 'package:flutter/material.dart';
import 'package:proyecto_final_construccion/screens/app_nav/profile/profile_screen.dart';

import 'agregar_receta/agregar_receta.dart';


class Recipe {
  final String title;
  final String author;
  final String imageUrl;

  Recipe({
    required this.title,
    required this.author,
    required this.imageUrl,
  });
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulación de recetas subidas por usuarios
    final List<Recipe> recetas = [
      Recipe(
        title: 'Bizcocho Tres leches',
        author: 'USUARIO',
        imageUrl: 'assets/images/bizcocho.jpg',
      ),
      Recipe(
        title: 'Albondigas con ensalada',
        author: 'USUARIO',
        imageUrl: 'assets/images/albondigas.jpg',
      ),
      Recipe(
        title: 'Cereal de frutas',
        author: 'USUARIO',
        imageUrl: 'assets/images/cereal.jpg',
      ),
      Recipe(
        title: 'Ensalada con salmon',
        author: 'USUARIO',
        imageUrl: 'assets/images/ensalada_salmon.jpg',
      ),
    ];

    // Simulación de recetas saludables
    final List<Map<String, String>> recetasSaludables = [
      {
        'titulo': 'Ensalada Cesar',
        'autor': 'Nutricionista',
        'imagen': 'assets/images/ensalada_cesar.jpg',
      },
      {
        'titulo': 'Salmón a la plancha',
        'autor': 'Chef Juan',
        'imagen': 'assets/images/salmon.jpg',
      },
      {
        'titulo': 'Pollo al horno',
        'autor': 'Chef Ana',
        'imagen': 'assets/images/pollo_horno.jpg',
      },
      {
        'titulo': 'Tazón de quinoa',
        'autor': 'USUARIO',
        'imagen': 'assets/images/quinoa.jpg',
      },
    ];

    // Simulación de recetas top recomendadas
    final List<Map<String, String>> topRecomendados = [
      {
        'titulo': 'Pizza Margarita',
        'autor': 'Chef Luigi',
        'imagen': 'assets/images/pizza.jpg',
      },
      {
        'titulo': 'Hamburguesa Clásica',
        'autor': 'Chef Gordon',
        'imagen': 'assets/images/hamburguesa.jpg',
      },
      {
        'titulo': 'Sushi Variado',
        'autor': 'Chef Saito',
        'imagen': 'assets/images/sushi.jpg',
      },
      {
        'titulo': 'Pasta Alfredo',
        'autor': 'Chef Maria',
        'imagen': 'assets/images/pasta.jpg',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4EB),
      body: Stack(
        children: [
          // Contenido principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Saludo
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Hey User, ',
                            style: TextStyle(
                              color: Color(0xFF1E1D1D),
                              fontSize: 16,
                              fontFamily: 'Fira Code',
                              fontWeight: FontWeight.w400,
                              height: 1.62,
                            ),
                          ),
                          TextSpan(
                            text: 'Que vamos a realizar?!',
                            style: TextStyle(
                              color: Color(0xFF1E1D1D),
                              fontSize: 16,
                              fontFamily: 'Fira Code',
                              fontWeight: FontWeight.w600,
                              height: 1.62,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Buscador
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Buscar Recetas',
                        hintStyle: TextStyle(
                          color: Color(0xFF676767),
                          fontSize: 14,
                          fontFamily: 'Khula',
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF676767)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Categoría y "Ver todos"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Categoría',
                          style: TextStyle(
                            color: Color(0xFF31343D),
                            fontSize: 20,
                            fontFamily: 'Khula',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'Ver todos',
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 16,
                            fontFamily: 'Khula',
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.33,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Filtros de categoría
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            width: 100,
                            height: 44,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFD27C),
                              borderRadius: BorderRadius.circular(39),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFFEFE6E1),
                                  blurRadius: 30,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Color(0xFFFF7621),
                              borderRadius: BorderRadius.circular(23),
                            ),
                          ),
                          Text(
                            'All',
                            style: TextStyle(
                              color: Color(0xFF32343E),
                              fontSize: 14,
                              fontFamily: 'Fira Code',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 44,
                            height: 44,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Color(0xB2FA851D),
                              borderRadius: BorderRadius.circular(23),
                            ),
                          ),
                          Text(
                            'Comida rapida',
                            style: TextStyle(
                              color: Color(0xFF32343E),
                              fontSize: 14,
                              fontFamily: 'Fira Code',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 44,
                            height: 44,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: Color(0xB2FA851D),
                              borderRadius: BorderRadius.circular(23),
                            ),
                          ),
                          Text(
                            'Vegano',
                            style: TextStyle(
                              color: Color(0xFF32343E),
                              fontSize: 14,
                              fontFamily: 'Fira Code',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Top recomendados y "Ver todos"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Top recomendados',
                          style: TextStyle(
                            color: Color(0xFF31343D),
                            fontSize: 20,
                            fontFamily: 'Khula',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'Ver todos',
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 16,
                            fontFamily: 'Khula',
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.33,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Grid de recetas top recomendados
                    SizedBox(
                      height: 180,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: topRecomendados.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          final receta = topRecomendados[index];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Stack(
                              children: [
                                Image.asset(
                                  receta['imagen']!,
                                  width: 140,
                                  height: 180,
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  width: 140,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 12,
                                  bottom: 24,
                                  right: 12,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        receta['titulo']!,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontFamily: 'Khula',
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: -0.33,
                                        ),
                                      ),
                                      Text(
                                        'Creado por ${receta['autor']}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'Khula',
                                          fontWeight: FontWeight.w300,
                                          letterSpacing: -0.33,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recetas saludables y "Ver todos"
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recetas saludables',
                          style: TextStyle(
                            color: Color(0xFF31343D),
                            fontSize: 20,
                            fontFamily: 'Khula',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'Ver todos',
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 16,
                            fontFamily: 'Khula',
                            fontWeight: FontWeight.w400,
                            letterSpacing: -0.33,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Grid de recetas saludables
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: recetasSaludables.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.75,
                      ),
                      itemBuilder: (context, index) {
                        final receta = recetasSaludables[index];
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Image.asset(
                                receta['imagen']!,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 12,
                                bottom: 24,
                                right: 12,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      receta['titulo']!,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Khula',
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: -0.33,
                                      ),
                                    ),
                                    Text(
                                      'Creado por ${receta['autor']}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontFamily: 'Khula',
                                        fontWeight: FontWeight.w300,
                                        letterSpacing: -0.33,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Espacio para el navegador inferior
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ),

          // Navegador transparente flotante
          // Navegador transparente flotante
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
                    const Positioned(
                      left: 11,
                      top: 8.5,
                      child: Icon(Icons.home, color: Colors.black, size: 24),
                    ),

                    // Ícono + con navegación a AgregarRecetaScreen
                    Positioned(
                      left: 70,
                      top: 5,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AgregarRecetaScreen()),
                          );
                        },
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
                    ),

                    // Ícono Perfil con navegación
                    Positioned(
                      left: 141,
                      top: 8.5,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProfileScreen()),
                          );
                        },
                        child: const Icon(Icons.person, color: Colors.black, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}