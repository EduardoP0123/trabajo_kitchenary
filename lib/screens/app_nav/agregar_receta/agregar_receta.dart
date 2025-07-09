import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../api/api_service.dart';
import '../home_screen.dart';
import '../profile/profile_screen.dart';

class AgregarRecetaScreen extends StatefulWidget {
  const AgregarRecetaScreen({super.key});

  @override
  State<AgregarRecetaScreen> createState() => _AgregarRecetaScreenState();
}

class _AgregarRecetaScreenState extends State<AgregarRecetaScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _tiempoPreparacionController = TextEditingController();
  final List<TextEditingController> _pasosControllers = [TextEditingController()];
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  File? _imagen;
  final ImagePicker _picker = ImagePicker();
  int _selectedCategoryId = 1;

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (!available) {
      if (mounted) {
        EasyLoading.showError('El reconocimiento de voz no está disponible');
      }
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _descripcionController.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imagen = File(pickedFile.path);
      });
    }
  }

  void _addNewStep() {
    if (_pasosControllers.last.text.isNotEmpty) {
      setState(() {
        _pasosControllers.add(TextEditingController());
      });
    } else {
      EasyLoading.showInfo('Complete el paso actual antes de agregar otro');
    }
  }

  bool _validateFields() {
    if (_tituloController.text.isEmpty) {
      EasyLoading.showError('El título es obligatorio');
      return false;
    }
    if (_descripcionController.text.isEmpty) {
      EasyLoading.showError('La descripción es obligatoria');
      return false;
    }
    if (_tiempoPreparacionController.text.isEmpty) {
      EasyLoading.showError('El tiempo de preparación es obligatorio');
      return false;
    }
    if (_pasosControllers.isEmpty || _pasosControllers.first.text.isEmpty) {
      EasyLoading.showError('Debe agregar al menos un paso');
      return false;
    }
    if (_imagen == null) {
      EasyLoading.showError('Debe seleccionar una imagen');
      return false;
    }
    return true;
  }

  Future<void> _guardarReceta() async {
    if (!_validateFields()) return;

    try {
      EasyLoading.show(status: 'Guardando receta...');

      // Filtrar solo los pasos con contenido
      final List<String> pasos = _pasosControllers
          .where((controller) => controller.text.isNotEmpty)
          .map((controller) => controller.text)
          .toList();

      // Convertir los pasos en un formato para guardar
      final String pasosTexto = pasos.asMap()
          .entries
          .map((entry) => '${entry.key + 1}. ${entry.value}')
          .join('\n');

      // OBTENER EL ID DE USUARIO
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;

      if (userId == 0) {
        EasyLoading.showError('Error: No se encontró el ID de usuario. Inicia sesión nuevamente.');
        return;
      }

      // Guardar la receta con el ID de usuario
      final result = await ApiService.saveRecipe(
        titulo: _tituloController.text,
        descripcion: _descripcionController.text,
        imagen: _imagen!,
        tiempoPreparacion: int.tryParse(_tiempoPreparacionController.text) ?? 0,
        pasos: pasosTexto,
        idCategoria: _selectedCategoryId,
        idUsuario: userId,
      );

      if (result['success'] == true) {
        EasyLoading.showSuccess('Receta guardada con éxito');
        Navigator.pop(context, true); // Para refrescar el HomeScreen
      } else {
        EasyLoading.showError('Error: ${result['message']}');
      }
    } catch (e) {
      EasyLoading.showError('Error al guardar receta: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4EB),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios, size: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Agregar nueva receta',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Fira Code',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Elige cómo agregar tu receta:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Khula',
                          ),
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInputOption(
                              icon: Icons.edit,
                              label: 'Texto',
                              onTap: () {},
                              isSelected: true,
                            ),
                            _buildInputOption(
                              icon: Icons.mic,
                              label: 'Voz',
                              onTap: _startListening,
                              isSelected: _isListening,
                            ),
                            _buildInputOption(
                              icon: Icons.camera_alt,
                              label: 'Foto',
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Seleccionar imagen'),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          leading: const Icon(Icons.photo_library),
                                          title: const Text('Galería'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _getImage(ImageSource.gallery);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(Icons.photo_camera),
                                          title: const Text('Cámara'),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _getImage(ImageSource.camera);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              isSelected: _imagen != null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_imagen != null) ...[
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(_imagen!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ] else ...[
                        GestureDetector(
                          onTap: () => _getImage(ImageSource.gallery),
                          child: Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                                SizedBox(height: 10),
                                Text('Añadir imagen de la receta', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                      TextField(
                        controller: _tituloController,
                        decoration: InputDecoration(
                          labelText: 'Título de la receta',
                          filled: true,
                          fillColor: const Color(0x72D9D9D9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _descripcionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          suffixIcon: IconButton(
                            icon: Icon(_isListening ? Icons.stop : Icons.mic),
                            onPressed: _startListening,
                          ),
                          filled: true,
                          fillColor: const Color(0x72D9D9D9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _tiempoPreparacionController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Tiempo de preparación (minutos)',
                          filled: true,
                          fillColor: const Color(0x72D9D9D9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Pasos de preparación:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (int i = 0; i < _pasosControllers.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFA851D),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${i + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _pasosControllers[i],
                                  maxLines: 2,
                                  onChanged: (value) {
                                    if (i == _pasosControllers.length - 1 && value.isNotEmpty) {
                                      if (value.length > 5) {
                                        setState(() {
                                          _pasosControllers.add(TextEditingController());
                                        });
                                      }
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: 'Describe el paso ${i + 1}',
                                    filled: true,
                                    fillColor: const Color(0x72D9D9D9),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _addNewStep,
                          icon: const Icon(Icons.add, color: Color(0xFFFA851D)),
                          label: const Text(
                            'Agregar otro paso',
                            style: TextStyle(color: Color(0xFFFA851D)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0x72D9D9D9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: _selectedCategoryId,
                            hint: const Text('Selecciona categoría'),
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('Desayuno')),
                              DropdownMenuItem(value: 2, child: Text('Almuerzo')),
                              DropdownMenuItem(value: 3, child: Text('Cena')),
                              DropdownMenuItem(value: 4, child: Text('Postre')),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedCategoryId = value!;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Container(
                          width: double.infinity,
                          height: 55,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFA851D).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFA851D),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.zero,
                              elevation: 0,
                            ),
                            onPressed: _guardarReceta,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
                                SizedBox(width: 10),
                                Text(
                                  'Publicar Receta',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // --- NAVBAR DISEÑO EXACTO ---
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

  Widget _buildInputOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFA851D) : const Color(0xFFE0E0E0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : Colors.black54,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFA851D) : Colors.black54,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}