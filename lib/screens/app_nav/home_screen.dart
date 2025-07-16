import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'profile/profile_screen.dart';
import 'recetas/recetas_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_service.dart';
import 'agregar_receta/agregar_receta.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Constantes
  static const Color primaryColor = Color(0xFFFA851D);
  static const Color backgroundColor = Color(0xFFFFF4EB);
  static const String apiBaseUrl = 'http://10.0.39.41:3000';

  // Variables de estado
  final List<dynamic> _misRecetas = [];
  final List<dynamic> _allRecetas = [];
  List<dynamic> _filteredRecetas = [];
  List<dynamic> _categorias = [];
  int? _selectedCategoriaId;
  bool _isLoadingRecetas = true;
  bool _hasError = false;
  String _userName = 'Usuario';
  int _userId = 0;
  String _searchText = '';

  final TextEditingController _searchController = TextEditingController();

  // Íconos para las categorías
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
    _initData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _initData() async {
    await _loadUserData();
    await Future.wait([
      _cargarCategorias(),
      _cargarRecetas(),
    ]);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _userId = prefs.getInt('userId') ?? 0;
        _userName = prefs.getString('userName') ??
            prefs.getString('userEmail') ?? 'Usuario';
      });
    } catch (e) {
      debugPrint('Error cargando datos del usuario: $e');
    }
  }

  Future<void> _cargarCategorias() async {
    try {
      // Cargar categorías predeterminadas mientras esperamos la API
      setState(() {
        _categorias = [
          {"id_categoria": 1, "nombre_categoria": "Desayuno"},
          {"id_categoria": 2, "nombre_categoria": "Almuerzo"},
          {"id_categoria": 3, "nombre_categoria": "Cena"},
          {"id_categoria": 4, "nombre_categoria": "Postre"},
        ];
      });

      final result = await ApiService.get('categorias');
      final data = jsonDecode(result.body);

      if (data['success'] == true && data['categorias'] != null &&
          data['categorias'].isNotEmpty && mounted) {
        setState(() {
          _categorias = data['categorias'];
        });
      }
    } catch (e) {
      debugPrint('Error cargando categorías: $e');
    }
  }

  Future<void> _cargarRecetas() async {
    if (!mounted) return;

    setState(() {
      _isLoadingRecetas = true;
      _hasError = false;
    });

    try {
      final result = await ApiService.getAllRecipes();

      if (result['success'] && mounted) {
        final allRecetas = result['recetas'];

        // Eliminar duplicados usando un Set
        final uniqueIds = <dynamic>{};
        final allRecetasUnicas = allRecetas.where((receta) =>
            uniqueIds.add(receta['id_receta'])
        ).toList();

        // Filtrar mis recetas
        final misRecetas = allRecetasUnicas.where((receta) =>
        receta['id_usuario'] == _userId
        ).toList();

        if (mounted) {
          setState(() {
            _allRecetas.clear();
            _allRecetas.addAll(allRecetasUnicas);

            _misRecetas.clear();
            _misRecetas.addAll(misRecetas);

            _isLoadingRecetas = false;
          });
          _filtrarRecetas();
        }
      } else if (mounted) {
        setState(() {
          _isLoadingRecetas = false;
          _hasError = true;
        });
      }
    } catch (e) {
      debugPrint('Error cargando recetas: $e');
      if (mounted) {
        setState(() {
          _isLoadingRecetas = false;
          _hasError = true;
        });
      }
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.trim().toLowerCase() != _searchText) {
      setState(() {
        _searchText = _searchController.text.trim().toLowerCase();
      });
      _filtrarRecetas();
    }
  }

  void _filtrarRecetas() {
    if (!mounted) return;

    List<dynamic> recetas = List.from(_allRecetas);

    if (_selectedCategoriaId != null) {
      recetas = recetas.where((receta) =>
      receta['id_categoria'] == _selectedCategoriaId
      ).toList();
    }

    if (_searchText.isNotEmpty) {
      recetas = recetas.where((receta) =>
          (receta['titulo'] ?? '').toString().toLowerCase().contains(_searchText)
      ).toList();
    }

    setState(() {
      _filteredRecetas = recetas;
    });
  }

  void _seleccionarCategoria(int? categoriaId) {
    setState(() {
      _selectedCategoriaId = categoriaId;
    });
    _filtrarRecetas();
  }

  void _navegarAReceta(dynamic receta) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecetasScreen(recetaSeleccionada: receta),
      ),
    );
  }

  void _navegarAAgregarReceta() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgregarRecetaScreen()),
    ).then((_) => _cargarRecetas());
  }

  void _navegarAPerfil() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ProfileScreen()),
    );
  }

  // WIDGETS REUTILIZABLES

  Widget _buildImageFromSource(String? imageSource) {
    if (imageSource == null || imageSource.isEmpty) {
      return Image.asset(
        'assets/images/placeholder.jpg',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.restaurant_menu, size: 50, color: Colors.grey),
          );
        },
      );
    }

    if (imageSource.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageSource,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2)
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 50),
        ),
      );
    }

    if (imageSource.startsWith('/uploads')) {
      final String fullUrl = '$apiBaseUrl$imageSource';
      return CachedNetworkImage(
        imageUrl: fullUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
            child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2)
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 50),
        ),
      );
    }

    try {
      return Image.memory(
        base64Decode(imageSource),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 50),
        ),
      );
    } catch (e) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.broken_image, size: 50),
      );
    }
  }

  Widget _buildRecipeCard(dynamic receta) {
    final String title = receta['titulo'] ?? 'Sin título';
    final String author = receta['nombre_usuario'] ??
        receta['correo_usuario'] ?? 'Usuario';

    return GestureDetector(
      onTap: () => _navegarAReceta(receta),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            SizedBox(
              width: 140,
              height: 180,
              child: _buildImageFromSource(receta['imagen']),
            ),
            // Gradiente para mejorar legibilidad del texto
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
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Khula',
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.33,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Por $author',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'Khula',
                      fontWeight: FontWeight.w300,
                      letterSpacing: -0.33,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriaButton(dynamic categoria, {bool isAll = false}) {
    final bool isSelected = isAll
        ? _selectedCategoriaId == null
        : _selectedCategoriaId == categoria['id_categoria'];

    final String nombre = isAll ? 'All' : categoria['nombre_categoria'] ?? '';
    final IconData icon = categoriaIcons[nombre] ?? Icons.category;

    return GestureDetector(
      onTap: () => _seleccionarCategoria(isAll ? null : categoria['id_categoria']),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        height: 50,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFA726) : backgroundColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
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
              backgroundColor: const Color(0xFFFF7621),
              radius: 16,
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              nombre,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Fira Code',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF31343D),
            fontSize: 20,
            fontFamily: 'Khula',
            fontWeight: FontWeight.w400,
          ),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: const Row(
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
    );
  }

  Widget _buildRecipeList(List<dynamic> recetas) {
    if (_isLoadingRecetas) {
      return const Center(
          child: CircularProgressIndicator(color: primaryColor)
      );
    }

    if (_hasError) {
      return const Center(
          child: Text('Error al cargar recetas')
      );
    }

    if (recetas.isEmpty) {
      return const Center(
          child: Text('No hay recetas disponibles')
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: recetas.length > 5 ? 5 : recetas.length,
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemBuilder: (_, index) => _buildRecipeCard(recetas[index]),
    );
  }

  Widget _buildNavBar() {
    return Container(
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
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen())
                );
              },
              child: const Icon(Icons.home, color: primaryColor, size: 24),
            ),
          ),
          // Ícono Añadir (activo)
          Positioned(
            left: 70,
            top: 5,
            child: GestureDetector(
              onTap: _navegarAAgregarReceta,
              child: Container(
                width: 36,
                height: 30,
                decoration: const BoxDecoration(
                  color: primaryColor,
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
              onTap: _navegarAPerfil,
              child: const Icon(Icons.person, color: Colors.black, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(16),
              child: RefreshIndicator(
                onRefresh: _cargarRecetas,
                color: primaryColor,
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
                              style: const TextStyle(
                                color: Color(0xFF1E1D1D),
                                fontSize: 16,
                                fontFamily: 'Fira Code',
                                fontWeight: FontWeight.w400,
                                height: 1.62,
                              ),
                            ),
                            const TextSpan(
                              text: '¿Qué vamos a realizar?',
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

                      // Barra de búsqueda
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Buscar Recetas',
                          hintStyle: const TextStyle(
                            color: Color(0xFF676767),
                            fontSize: 14,
                            fontFamily: 'Khula',
                            fontWeight: FontWeight.w400,
                          ),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF676767)),
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

                      // Categorías
                      _buildSectionHeader('Categoría', onViewAll: () => _seleccionarCategoria(null)),
                      const SizedBox(height: 12),

                      // Lista de categorías
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildCategoriaButton({}, isAll: true),
                            ..._categorias.map((cat) => _buildCategoriaButton(cat)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Recetas filtradas (condicional)
                      if (_selectedCategoriaId != null || _searchText.isNotEmpty) ...[
                        _buildSectionHeader('Filtrados'),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 180,
                          child: _buildRecipeList(_filteredRecetas),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Mis recetas
                      _buildSectionHeader('Mis recetas'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 180,
                        child: _buildRecipeList(_misRecetas),
                      ),
                      const SizedBox(height: 24),

                      // Top recomendados
                      _buildSectionHeader('Top recomendados'),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 180,
                        child: _buildRecipeList(_allRecetas),
                      ),
                      // Espacio para evitar que el navbar cubra contenido
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),

            // Barra de navegación
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: _buildNavBar(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}