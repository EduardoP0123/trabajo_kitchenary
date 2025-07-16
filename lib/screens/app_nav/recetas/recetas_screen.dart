import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../api/api_service.dart';
import '../agregar_receta/agregar_receta.dart';
import '../home_screen.dart';
import '../profile/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RecetasScreen extends StatefulWidget {
  final dynamic recetaSeleccionada;

  const RecetasScreen({Key? key, this.recetaSeleccionada}) : super(key: key);

  @override
  State<RecetasScreen> createState() => _RecetasScreenState();
}

class _RecetasScreenState extends State<RecetasScreen> with TickerProviderStateMixin {
  static const Color primaryColor = Color(0xFFFA851D);
  static const Color backgroundColor = Color(0xFFFFF4EB);
  static const String apiBaseUrl = 'http://192.168.100.250:3000';

  List<dynamic> _recetas = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  dynamic _recetaSeleccionada;
  late TabController _tabController;
  int _currentUserId = 0;
  Map<String, dynamic> _creatorData = {};
  List<dynamic> _comments = [];
  final TextEditingController _commentController = TextEditingController();
  bool _isLoadingComments = false;
  double _userRating = 0;
  bool _isSubmittingRating = false;
  double _averageRating = 0.0;
  int _ratingCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _checkConnectivity();
    _cargarRecetas();
    _loadUserData();

    if (widget.recetaSeleccionada != null) {
      _recetaSeleccionada = widget.recetaSeleccionada;
      _loadCreatorData(_recetaSeleccionada['id_usuario']);
      _loadComments(_recetaSeleccionada['id_receta']);
      _loadUserRating(_recetaSeleccionada['id_receta']);
      _loadAverageRating(_recetaSeleccionada['id_receta']);
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('192.168.100.250');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        debugPrint("Conectividad confirmada con el servidor");
      }
    } on SocketException catch (_) {
      debugPrint("No hay conectividad con el servidor");
      setState(() {
        _hasError = true;
        _errorMessage = 'No se pudo conectar al servidor. Verifica tu conexión.';
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');
      debugPrint("ID de usuario cargado: $userId");

      if (mounted) {
        setState(() {
          _currentUserId = userId ?? 0;
        });
      }
    } catch (e) {
      debugPrint("Error cargando datos de usuario: $e");
    }
  }

  Future<void> _loadUserRating(int? recetaId) async {
    if (recetaId == null || _currentUserId == 0) return;
    try {
      final data = await ApiService.getUserRatingForRecipe(_currentUserId, recetaId);
      if (data['success'] && data['valoracion'] != null && mounted) {
        setState(() {
          _userRating = (data['valoracion']['valor'] ?? 0).toDouble();
        });
        debugPrint("Valoración del usuario cargada: $_userRating");
      }
    } catch (e) {
      debugPrint("Error cargando valoración del usuario: $e");
    }
  }

  Future<void> _loadAverageRating(int? recetaId) async {
    if (recetaId == null) return;
    try {
      final data = await ApiService.getAverageRating(recetaId);
      if (mounted) {
        setState(() {
          _averageRating = data['promedio'];
          _ratingCount = data['cantidad'];
        });
        debugPrint("Valoración promedio cargada: $_averageRating ($_ratingCount)");
      }
    } catch (e) {
      debugPrint("Error cargando valoración promedio: $e");
    }
  }

  Future<void> _submitRating(double rating) async {
    if (_isSubmittingRating || _currentUserId == 0 ||
        _recetaSeleccionada == null || _recetaSeleccionada['id_receta'] == null) return;

    setState(() {
      _isSubmittingRating = true;
    });

    try {
      final result = await ApiService.rateRecipe(
        _recetaSeleccionada['id_receta'],
        _currentUserId,
        rating.toInt(),
      );

      if (result['success'] && mounted) {
        setState(() {
          _userRating = rating;
        });
        await _loadAverageRating(_recetaSeleccionada['id_receta']);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Gracias por tu valoración!'),
            backgroundColor: primaryColor,
            duration: Duration(seconds: 2),
          ),
        );
        debugPrint("Valoración enviada correctamente");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo guardar la valoración'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error enviando valoración: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al enviar valoración'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingRating = false;
        });
      }
    }
  }

  Future<void> _cargarRecetas() async {
    if (_hasError) return;

    setState(() { _isLoading = true; });
    try {
      final result = await ApiService.getAllRecipes();
      if (mounted) {
        setState(() {
          if (result['success']) {
            _recetas = result['recetas'] ?? [];
          } else {
            _hasError = true;
            _errorMessage = 'No se pudieron cargar las recetas';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = 'Error de conexión al cargar recetas';
        });
      }
    }
  }

  Future<void> _loadCreatorData(int? userId) async {
    if (userId == null) return;
    try {
      final result = await ApiService.getUserInfo(userId);
      if (result['success'] && mounted) {
        setState(() {
          _creatorData = result['usuario'] ?? {};
        });
      }
    } catch (e) {
      debugPrint("Error cargando datos del creador: $e");
    }
  }

  Future<void> _loadComments(int? recetaId) async {
    if (recetaId == null) return;

    setState(() { _isLoadingComments = true; });
    try {
      final result = await ApiService.getComments(recetaId);
      if (mounted) {
        setState(() {
          _comments = result['success'] ? result['comentarios'] ?? [] : [];
          _isLoadingComments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() { _isLoadingComments = false; });
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;
    if (_currentUserId == 0 || _recetaSeleccionada['id_receta'] == null) return;

    try {
      final result = await ApiService.addComment(
          _recetaSeleccionada['id_receta'],
          _currentUserId,
          _commentController.text.trim()
      );

      if (result['success'] && mounted) {
        _commentController.clear();
        _loadComments(_recetaSeleccionada['id_receta']);
      }
    } catch (e) {
      debugPrint("Error añadiendo comentario: $e");
    }
  }

  Widget _buildImage(String? url, {double? width, double? height}) {
    if (url == null || url.isEmpty) {
      return Image.asset(
        'assets/images/placeholder.jpg',
        fit: BoxFit.cover,
        width: width,
        height: height,
      );
    }

    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (_, error, __) {
          return Image.asset(
            'assets/images/placeholder.jpg',
            fit: BoxFit.cover,
            width: width,
            height: height,
          );
        },
      );
    }

    if (url.startsWith('/uploads')) {
      final String fullUrl = '$apiBaseUrl$url';
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (_, error, __) {
          return Image.asset(
            'assets/images/placeholder.jpg',
            fit: BoxFit.cover,
            width: width,
            height: height,
          );
        },
      );
    }

    try {
      return Image.memory(
        base64Decode(url),
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (_, error, __) {
          return Image.asset(
            'assets/images/placeholder.jpg',
            fit: BoxFit.cover,
            width: width,
            height: height,
          );
        },
      );
    } catch (e) {
      return Image.asset(
        'assets/images/placeholder.jpg',
        fit: BoxFit.cover,
        width: width,
        height: height,
      );
    }
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF7E7D9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: primaryColor, size: 18),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingChip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Promedio y cantidad de valoraciones
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFF7E7D9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 18),
              const SizedBox(width: 6),
              Text(
                "${_averageRating.toStringAsFixed(1)} (${_ratingCount})",
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Valoración del usuario
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFF7E7D9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Tu valoración:",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  RatingBar.builder(
                    initialRating: _userRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 20,
                    itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _userRating = rating;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: _isSubmittingRating ? null : () => _submitRating(_userRating),
                    icon: _isSubmittingRating
                        ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Icon(Icons.save, size: 16),
                    label: const Text("Guardar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      textStyle: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _customNavBar() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.only(bottom: 20),
      height: 70,
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
              Positioned(
                left: 70,
                top: 5,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AgregarRecetaScreen()),
                    ).then((_) => _cargarRecetas());
                  },
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
                  child: const Icon(Icons.person, color: Colors.black, size: 24)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<String> _parseStringList(dynamic data) {
    if (data == null) return [];

    if (data is String) {
      return data.split('\n')
          .where((String e) => e.trim().isNotEmpty)
          .toList();
    }

    if (data is List) {
      return data.map((e) => e.toString()).toList();
    }

    return [];
  }

  Widget _buildDetalle(dynamic receta) {
    final ingredientes = _parseStringList(receta['ingredientes']);
    final instrucciones = _parseStringList(receta['pasos'] ?? receta['instrucciones']);
    final String creatorName = _creatorData['nombre'] ?? receta['nombre_usuario'] ?? 'Usuario';
    final String? creatorImage = _creatorData['imagen_perfil'];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 240,
                      child: _buildImage(receta['imagen'], width: double.infinity, height: 240),
                    ),
                    Positioned(
                      top: 40,
                      left: 16,
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.8),
                        child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: primaryColor),
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const HomeScreen()));
                            }
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  decoration: const BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          receta['titulo'] ?? 'Sin título',
                          textAlign: TextAlign.left,
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      if ((receta['descripcion'] ?? '').toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            receta['descripcion'] ?? '',
                            style: const TextStyle(
                              color: Color(0xFF6B6B6B),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          _buildInfoChip(Icons.timer, "${receta['tiempo_preparacion'] ?? '40'}min"),
                          const SizedBox(width: 16),
                          Expanded(child: _buildRatingChip()),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: primaryColor,
                            backgroundImage: creatorImage != null ? NetworkImage(creatorImage) : null,
                            child: creatorImage == null ? const Icon(Icons.person, color: Colors.white) : null,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            creatorName,
                            style: const TextStyle(
                              color: Color(0xFF2D2D2D),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFA726),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                              elevation: 0,
                            ),
                            onPressed: () {},
                            child: const Text('Seguir', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.share, color: primaryColor),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7E7D9),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: const Color(0xFFFFA726),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: primaryColor,
                          tabs: const [
                            Tab(icon: Icon(Icons.list_alt), text: "Ingredientes"),
                            Tab(icon: Icon(Icons.auto_stories), text: "Instrucciones"),
                            Tab(icon: Icon(Icons.comment), text: "Comentarios"),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 220,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: ingredientes.isEmpty
                                    ? const Center(child: Text('No hay ingredientes registrados'))
                                    : SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: ingredientes.map((item) => Padding(
                                      padding: const EdgeInsets.only(bottom: 4),
                                      child: Text('• $item'),
                                    )).toList(),
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: instrucciones.isEmpty
                                    ? const Center(child: Text('No hay instrucciones registradas'))
                                    : SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: instrucciones.asMap().entries.map((e) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text('${e.key + 1}. ${e.value}'),
                                    )).toList(),
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: _commentController,
                                            decoration: InputDecoration(
                                              hintText: 'Añade un comentario...',
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(16),
                                                borderSide: BorderSide(color: Colors.grey.shade300),
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.send, color: primaryColor),
                                          onPressed: _addComment,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: _isLoadingComments
                                          ? const Center(child: CircularProgressIndicator(color: primaryColor))
                                          : _comments.isEmpty
                                          ? const Center(child: Text('No hay comentarios todavía'))
                                          : ListView.builder(
                                        itemCount: _comments.length,
                                        itemBuilder: (context, idx) {
                                          final comment = _comments[idx];
                                          return ListTile(
                                            leading: const CircleAvatar(
                                              backgroundColor: primaryColor,
                                              child: Icon(Icons.person, color: Colors.white, size: 18),
                                            ),
                                            title: Text(comment['nombre_usuario'] ?? 'Usuario'),
                                            subtitle: Text(comment['texto'] ?? ''),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _customNavBar(),
    );
  }

  Widget _buildErrorIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: primaryColor,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _hasError = false;
                _errorMessage = '';
              });
              _checkConnectivity();
              _cargarRecetas();
            },
            child: const Text('Reintentar'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_recetaSeleccionada != null) {
      return _buildDetalle(_recetaSeleccionada);
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Recetas'),
        backgroundColor: primaryColor,
      ),
      body: Stack(
        children: [
          if (_hasError)
            _buildErrorIndicator()
          else if (_isLoading)
            const Center(child: CircularProgressIndicator(color: primaryColor))
          else if (_recetas.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.restaurant,
                      color: primaryColor,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay recetas disponibles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AgregarRecetaScreen(),
                          ),
                        ).then((_) => _cargarRecetas());
                      },
                      child: const Text('Añadir una receta'),
                    )
                  ],
                ),
              )
            else
              GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _recetas.length,
                itemBuilder: (context, index) {
                  final receta = _recetas[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _recetaSeleccionada = receta;
                        _tabController = TabController(length: 3, vsync: this);
                        _creatorData = {};
                        _comments = [];
                        _isLoadingComments = false;
                      });
                      _loadCreatorData(receta['id_usuario']);
                      _loadComments(receta['id_receta']);
                      _loadUserRating(receta['id_receta']);
                      _loadAverageRating(receta['id_receta']);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildImage(receta['imagen']),
                          Container(
                            decoration: BoxDecoration(
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
                            bottom: 12,
                            left: 12,
                            right: 12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  receta['titulo'] ?? 'Sin título',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Por ${receta['nombre_usuario'] ?? 'Usuario'}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        ],
      ),
      bottomNavigationBar: _customNavBar(),
    );
  }
}