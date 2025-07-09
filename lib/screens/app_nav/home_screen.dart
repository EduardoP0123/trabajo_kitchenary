import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:proyecto_final_construccion/screens/app_nav/profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_service.dart';
import 'agregar_receta/agregar_receta.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _misRecetas = [];
  List<dynamic> _allRecetas = [];
  List<dynamic> _filteredRecetas = [];
  List<dynamic> _categorias = [];
  int? _selectedCategoriaId;
  bool _isLoadingRecetas = true;
  bool _hasError = false;
  String _userEmail = 'Usuario';
  String _userName = 'Usuario';
  int _userId = 0;
  String _searchText = '';

  final TextEditingController _searchController = TextEditingController();

  // Íconos correctos para las categorías
  final Map<String, IconData> categoriaIcons = {
    'All': Icons.restaurant_menu,
    'Desayuno': Icons.free_breakfast,
    'Almuerzo': Icons.lunch_dining,
    'Cena': Icons.dinner_dining,
    'Postre': Icons.cake,
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _cargarCategorias();
    _cargarRecetas();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('userEmail') ?? 'Usuario';
      final userId = prefs.getInt('userId') ?? 0;
      final name = prefs.getString('userName') ?? email;

      setState(() {
        _userEmail = email;
        _userId = userId;
        _userName = name;
      });
    } catch (e) {
      print('Error cargando datos del usuario: $e');
    }
  }

  Future<void> _cargarCategorias() async {
    try {
      // Categorías fijas para asegurar visibilidad
      setState(() {
        _categorias = [
          {"id_categoria": 1, "nombre_categoria": "Desayuno"},
          {"id_categoria": 2, "nombre_categoria": "Almuerzo"},
          {"id_categoria": 3, "nombre_categoria": "Cena"},
          {"id_categoria": 4, "nombre_categoria": "Postre"},
        ];
      });

      // Intenta cargar desde API después
      final result = await ApiService.get('categorias');
      final data = jsonDecode(result.body);
      if (data['success'] == true && data['categorias'] != null && data['categorias'].isNotEmpty) {
        setState(() {
          _categorias = data['categorias'];
        });
      }
    } catch (e) {
      print('Error cargando categorías: $e');
    }
  }

  Future<void> _cargarRecetas() async {
    setState(() {
      _isLoadingRecetas = true;
      _hasError = false;
    });

    try {
      final result = await ApiService.getAllRecipes();

      if (result['success']) {
        final allRecetas = result['recetas'];
        final misRecetas = allRecetas.where((receta) =>
        receta['id_usuario'] == _userId
        ).toList();

        setState(() {
          _allRecetas = allRecetas;
          _misRecetas = misRecetas;
          _isLoadingRecetas = false;
        });
        _filtrarRecetas();
      } else {
        setState(() {
          _isLoadingRecetas = false;
          _hasError = true;
        });
      }
    } catch (e) {
      print('Error cargando recetas: $e');
      setState(() {
        _isLoadingRecetas = false;
        _hasError = true;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchText = _searchController.text.trim().toLowerCase();
    });
    _filtrarRecetas();
  }

  void _filtrarRecetas() {
    List<dynamic> recetas = _allRecetas;

    // Filtrar por categoría si hay una seleccionada
    if (_selectedCategoriaId != null) {
      recetas = recetas.where((receta) =>
      receta['id_categoria'] == _selectedCategoriaId
      ).toList();
    }

    // Filtrar por texto de búsqueda
    if (_searchText.isNotEmpty) {
      recetas = recetas.where((receta) =>
          (receta['titulo'] ?? '').toString().toLowerCase().contains(_searchText)
      ).toList();
    }

    setState(() {
      _filteredRecetas = recetas;
    });
  }

  Widget _buildImageFromSource(String? imageSource) {
    if (imageSource == null) {
      return Image.asset(
        'assets/images/placeholder.jpg',
        fit: BoxFit.cover,
      );
    }

    // Prioriza URLs de Cloudinary o cualquier URL http
    if (imageSource.startsWith('http')) {
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 50),
          );
        },
      );
    } else if (imageSource.startsWith('/uploads')) {
      // Mantener compatibilidad con URLs antiguas
      final String fullUrl = 'http://10.0.39.41:3000$imageSource';
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 50),
          );
        },
      );
    } else {
      try {
        // Intenta decodificar base64 como último recurso
        return Image.memory(
          base64Decode(imageSource),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 50),
            );
          },
        );
      } catch (e) {
        return Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 50),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4EB),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: RefreshIndicator(
                onRefresh: _cargarRecetas,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Saludo
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Hey $_userName, ',
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
                        controller: _searchController,
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
                        onChanged: (value) => _onSearchChanged(),
                      ),
                      const SizedBox(height: 24),

                      // Categoría y "Ver todos"
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Categoria',
                            style: TextStyle(
                              color: Color(0xFF31343D),
                              fontSize: 20,
                              fontFamily: 'Khula',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedCategoriaId = null;
                                _filtrarRecetas();
                              });
                            },
                            child: Row(
                              children: [
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
                                Icon(Icons.chevron_right, size: 18, color: Color(0xFF333333)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Filtros de categoría con iconos
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Botón "All"
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategoriaId = null;
                                  _filtrarRecetas();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                height: 50,
                                margin: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: _selectedCategoriaId == null ? Color(0xFFFFA726) : Color(0xFFFFF4EB),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Color(0xFFFF7621),
                                      radius: 16,
                                      child: Icon(Icons.restaurant_menu, color: Colors.white, size: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'All',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Fira Code',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Botones de categorías desde la DB
                            ..._categorias.map((cat) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedCategoriaId = cat['id_categoria'];
                                  _filtrarRecetas();
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18),
                                height: 44,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: _selectedCategoriaId == cat['id_categoria'] ? Color(0xFFFFA726) : Color(0xFFFFF4EB),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 6,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Color(0xFFFF7621),
                                      radius: 16,
                                      child: Icon(
                                        categoriaIcons[cat['nombre_categoria']] ?? Icons.category,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      cat['nombre_categoria'] ?? '',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Fira Code',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Apartado FILTRADOS (solo si hay filtro activo)
                      if (_selectedCategoriaId != null || _searchText.isNotEmpty) ...[
                        Text(
                          'Filtrados',
                          style: TextStyle(
                            color: Color(0xFF31343D),
                            fontSize: 20,
                            fontFamily: 'Khula',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 180,
                          child: _isLoadingRecetas
                              ? const Center(child: CircularProgressIndicator(color: Color(0xFFFA851D)))
                              : _hasError
                              ? const Center(child: Text('Error al cargar recetas'))
                              : _filteredRecetas.isEmpty
                              ? const Center(child: Text('No hay recetas filtradas'))
                              : ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _filteredRecetas.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 16),
                            itemBuilder: (context, index) {
                              final receta = _filteredRecetas[index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: 140,
                                      height: 180,
                                      child: _buildImageFromSource(receta['imagen']),
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
                                            receta['titulo'] ?? 'Sin título',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: 'Khula',
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: -0.33,
                                            ),
                                          ),
                                          Text(
                                            'Por ${receta['nombre_usuario'] ?? receta['correo_usuario'] ?? 'Usuario'}',
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
                      ],

                      // Mis recetas
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Mis recetas',
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

                      // Mostrar mis recetas (de la API)
                      SizedBox(
                        height: 180,
                        child: _isLoadingRecetas
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFA851D)))
                            : _hasError
                            ? const Center(child: Text('Error al cargar recetas'))
                            : _misRecetas.isEmpty
                            ? const Center(child: Text('No tienes recetas guardadas')) : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _misRecetas.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final receta = _misRecetas[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  SizedBox(
                                    width: 140,
                                    height: 180,
                                    child: _buildImageFromSource(receta['imagen']),
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
                                          receta['titulo'] ?? 'Sin título',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'Khula',
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.33,
                                          ),
                                        ),
                                        Text(
                                          'Por ${receta['nombre_usuario'] ?? receta['correo_usuario'] ?? _userEmail}',
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

                      // Grid de recetas top recomendados (sin filtro)
                      SizedBox(
                        height: 180,
                        child: _isLoadingRecetas
                            ? const Center(child: CircularProgressIndicator(color: Color(0xFFFA851D)))
                            : _hasError
                            ? const Center(child: Text('Error al cargar recetas'))
                            : _allRecetas.isEmpty
                            ? const Center(child: Text('No hay recetas disponibles'))
                            : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _allRecetas.length > 5 ? 5 : _allRecetas.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 16),
                          itemBuilder: (context, index) {
                            final receta = _allRecetas[index];
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                children: [
                                  SizedBox(
                                    width: 140,
                                    height: 180,
                                    child: _buildImageFromSource(receta['imagen']),
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
                                          receta['titulo'] ?? 'Sin título',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'Khula',
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: -0.33,
                                          ),
                                        ),
                                        Text(
                                          'Por ${receta['nombre_usuario'] ?? receta['correo_usuario'] ?? 'Usuario'}',
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

                      const SizedBox(height: 100), // Más espacio para evitar que el navbar tape contenido
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Navegador flotante SIN BORDE/LIMITANTE
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
                    // Ícono Agregar receta
                    Positioned(
                      left: 70,
                      top: 5,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AgregarRecetaScreen()),
                          ).then((value) {
                            if (value == true) {
                              _cargarRecetas();
                            }
                          });
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
                    // Ícono Perfil
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
          ),
        ],
      ),
    );
  }
}