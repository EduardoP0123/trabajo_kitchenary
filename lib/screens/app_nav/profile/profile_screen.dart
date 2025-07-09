import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:proyecto_final_construccion/api/api_service.dart';
import 'package:proyecto_final_construccion/screens/app_nav/home_screen.dart';
import 'package:proyecto_final_construccion/screens/app_nav/agregar_receta/agregar_receta.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  bool showLikes = true;
  late AnimationController _controller;
  late Animation<double> _circlePosition;

  int _userId = 0;
  String _userEmail = 'User';
  String _userName = 'User';
  String? _profileImageUrl;
  List<dynamic> _userRecipes = [];
  List<dynamic> _likedRecipes = [];
  bool _isLoading = true;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _circlePosition = Tween<double>(begin: 0, end: 53).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _loadUserData();
    _loadUserRecipes();
  }

  // Carga datos del usuario
  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('userEmail') ?? 'User';
      final userId = prefs.getInt('userId') ?? 0;
      final name = prefs.getString('userName') ?? email;
      final profileImage = prefs.getString('profileImage');

      setState(() {
        _userEmail = email;
        _userId = userId;
        _userName = name;
        _profileImageUrl = profileImage;
      });
    } catch (e) {
      print('Error cargando datos del usuario: $e');
    }
  }

  // Carga las recetas del usuario
  Future<void> _loadUserRecipes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiService.getAllRecipes();

      if (result['success']) {
        final allRecetas = result['recetas'];
        final userRecipes = allRecetas.where((receta) =>
        receta['id_usuario'] == _userId
        ).toList();

        // Por ahora, simularemos que le dio like a algunas recetas aleatorias
        final likedRecipes = allRecetas.where((receta) =>
        receta['id_usuario'] != _userId
        ).take(5).toList();

        setState(() {
          _userRecipes = userRecipes;
          _likedRecipes = likedRecipes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando recetas: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Maneja la edición del perfil
  Future<void> _handleEditProfile() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF4EB),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Editar Perfil',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Color(0xFFFA851D)),
              title: const Text('Cambiar foto de perfil'),
              onTap: () async {
                Navigator.pop(context);
                await _changeProfilePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFFFA851D)),
              title: const Text('Editar nombre de usuario'),
              onTap: () {
                Navigator.pop(context);
                _editUserName();
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit_note, color: Color(0xFFFA851D)),
              title: const Text('Editar mis recetas'),
              onTap: () {
                Navigator.pop(context);
                _editUserRecipes();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Cambiar foto de perfil
  Future<void> _changeProfilePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    // Aquí implementarías la subida a Cloudinary
    // Por ahora solo guardamos localmente para demostración
    final prefs = await SharedPreferences.getInstance();
    // En un caso real, aquí subirías la imagen a Cloudinary y guardarías la URL
    await prefs.setString('profileImage', image.path);

    setState(() {
      _profileImageUrl = image.path;
    });
  }

  // Editar nombre de usuario
  void _editUserName() {
    final TextEditingController nameController = TextEditingController(text: _userName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar nombre'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Nuevo nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              // Aquí implementarías la actualización en el backend
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('userName', nameController.text);
              setState(() {
                _userName = nameController.text;
              });
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Editar recetas del usuario
  void _editUserRecipes() {
    // Navegar a una vista donde el usuario pueda editar sus recetas
    // Por ahora solo navegamos a la pantalla de agregar receta
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AgregarRecetaScreen()),
    ).then((_) {
      _loadUserRecipes();
    });
  }

  void _toggleTab(bool likes) {
    if (likes != showLikes) {
      setState(() {
        showLikes = likes;
        if (showLikes) {
          _controller.reverse();
        } else {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildRecipeImage(dynamic receta) {
    // Si no hay receta, mostrar un contenedor vacío
    if (receta == null) {
      return Container(
        width: 156,
        height: 154,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: const Center(child: Text('No hay recetas')),
      );
    }

    // Determinar la fuente de la imagen
    Widget imageWidget;

    if (receta['imagen'] == null) {
      // Imagen predeterminada si no hay imagen
      imageWidget = Image.asset('assets/images/placeholder.jpg', fit: BoxFit.cover);
    } else if (receta['imagen'].toString().startsWith('http')) {
      // Imagen desde URL (Cloudinary)
      imageWidget = Image.network(receta['imagen'], fit: BoxFit.cover,
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
    } else if (receta['imagen'].toString().startsWith('/uploads')) {
      // Imagen desde el servidor local
      imageWidget = Image.network(
        'http://10.0.39.41:3000${receta['imagen']}',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, size: 50),
          );
        },
      );
    } else {
      // Imagen en base64
      try {
        imageWidget = Image.memory(
          base64Decode(receta['imagen']),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, size: 50),
            );
          },
        );
      } catch (e) {
        imageWidget = Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 50),
        );
      }
    }

    // Contenedor final con título
    return Container(
      width: 156,
      height: 154,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 156,
              height: 154,
              child: imageWidget,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
              ),
              child: Text(
                receta['titulo'] ?? 'Sin título',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determinar qué recetas mostrar según la pestaña seleccionada
    final List<dynamic> recipesToShow = showLikes ? _likedRecipes : _userRecipes;

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

          // Botón de editar (NUEVO)
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: _handleEditProfile,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit,
                  color: Color(0xFFFA851D),
                  size: 24,
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
              ),
              child: _profileImageUrl != null && _profileImageUrl!.startsWith('/')
                  ? ClipOval(
                child: Image.file(
                  File(_profileImageUrl!),
                  fit: BoxFit.cover,
                ),
              )
                  : _profileImageUrl != null && _profileImageUrl!.startsWith('http')
                  ? ClipOval(
                child: Image.network(
                  _profileImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Image.asset('assets/images/profile_placeholder.png', fit: BoxFit.cover),
                ),
              )
                  : ClipOval(
                child: Image.asset('assets/images/profile_placeholder.png', fit: BoxFit.cover),
              ),
            ),
          ),

          // Nombre de usuario
          Positioned(
            left: 131,
            top: 119,
            child: SizedBox(
              width: 200,
              height: 30,
              child: Text(
                _userName,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontFamily: 'Khula',
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),

          // Contador de recetas
          Positioned(
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
                    '${_userRecipes.length}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontFamily: 'Khula',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                const SizedBox(
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

          // Toggle de "Me gusta" / "Guardados" con animación
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
              child: Stack(
                children: [
                  // Animated orange circle
                  AnimatedBuilder(
                    animation: _circlePosition,
                    builder: (context, child) {
                      return Positioned(
                        left: 22 + _circlePosition.value,
                        top: 1,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const ShapeDecoration(
                            color: Color(0xFFFA851D),
                            shape: OvalBorder(),
                          ),
                        ),
                      );
                    },
                  ),
                  // Likes button
                  Positioned(
                    left: 23,
                    top: 3,
                    child: GestureDetector(
                      onTap: () => _toggleTab(true),
                      child: Icon(
                        Icons.favorite,
                        color: showLikes ? Colors.white : Colors.black,
                        size: 20,
                      ),
                    ),
                  ),
                  // Saved button
                  Positioned(
                    left: 79,
                    top: 3,
                    child: GestureDetector(
                      onTap: () => _toggleTab(false),
                      child: Icon(
                        Icons.bookmark_outlined,
                        color: showLikes ? Colors.black : Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Cuadrícula de recetas (likes o guardados)
          Positioned(
            left: 43,
            top: 325,
            child: SizedBox(
              width: 344,
              height: 514,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFA851D)))
                  : recipesToShow.isEmpty
                  ? Center(
                child: Text(
                  showLikes ? 'No hay recetas con like' : 'No has publicado recetas',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              )
                  : Column(
                children: [
                  if (recipesToShow.length > 0) Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRecipeImage(
                        recipesToShow.length > 0 ? recipesToShow[0] : null,
                      ),
                      _buildRecipeImage(
                        recipesToShow.length > 1 ? recipesToShow[1] : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  if (recipesToShow.length > 2) Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRecipeImage(
                        recipesToShow.length > 2 ? recipesToShow[2] : null,
                      ),
                      _buildRecipeImage(
                        recipesToShow.length > 3 ? recipesToShow[3] : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  if (recipesToShow.length > 4) Row(
                    children: [
                      _buildRecipeImage(
                        recipesToShow.length > 4 ? recipesToShow[4] : null,
                      ),
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
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const HomeScreen())
                          );
                        },
                        child: const Icon(Icons.home, color: Colors.black, size: 24),
                      ),
                    ),
                    // Ícono Agregar
                    Positioned(
                      left: 70,
                      top: 5,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AgregarRecetaScreen()),
                          ).then((_) {
                            _loadUserRecipes();
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
}