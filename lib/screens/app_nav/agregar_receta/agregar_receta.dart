import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AgregarRecetaScreen extends StatefulWidget {
  const AgregarRecetaScreen({super.key});

  @override
  State<AgregarRecetaScreen> createState() => _AgregarRecetaScreenState();
}

class _AgregarRecetaScreenState extends State<AgregarRecetaScreen> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _tiempoPreparacionController = TextEditingController();
  final TextEditingController _pasosController = TextEditingController();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  File? _imagen;
  final ImagePicker _picker = ImagePicker();
  int _selectedCategoryId = 1; // Categoría predeterminada

  Future<void> _initializeSpeech() async {
    bool available = await _speech.initialize();
    if (!available) {
      // El reconocimiento de voz no está disponible
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El reconocimiento de voz no está disponible en este dispositivo')),
      );
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

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Receta'),
        backgroundColor: const Color(0xFFFA851D),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agregar nueva receta',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Fira Code',
              ),
            ),
            const SizedBox(height: 20),

            // Métodos de entrada
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4EB),
                borderRadius: BorderRadius.circular(12),
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

                  // Opciones de entrada
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Opción: Texto
                      _buildInputOption(
                        icon: Icons.edit,
                        label: 'Texto',
                        onTap: () {
                          // Ya estamos en el modo texto por defecto
                        },
                        isSelected: true,
                      ),

                      // Opción: Voz
                      _buildInputOption(
                        icon: Icons.mic,
                        label: 'Voz',
                        onTap: _startListening,
                        isSelected: _isListening,
                      ),

                      // Opción: Foto
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

            // Formulario de receta
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen seleccionada
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
                ],

                // Campo Título
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

                // Campo Descripción
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

                // Tiempo de preparación
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

                // Pasos
                TextField(
                  controller: _pasosController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Pasos de preparación',
                    filled: true,
                    fillColor: const Color(0x72D9D9D9),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Categoría (Dropdown)
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

                // Botón Agregar ingredientes
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFA851D),
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      // Lógica para navegar a la pantalla de ingredientes
                      // O mostrar un diálogo para agregar ingredientes
                    },
                    child: const Text(
                      'Agregar Ingredientes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón Guardar
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF12372A),
                      padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      // Lógica para guardar la receta en la base de datos
                      // Aquí implementarías la lógica para guardar todos los campos
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('¡Receta guardada con éxito!')),
                      );
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Guardar Receta',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
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