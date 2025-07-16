import 'package:flutter/material.dart';

class DetalleRecetaScreen extends StatefulWidget {
  final dynamic recetaSeleccionada;

  const DetalleRecetaScreen({Key? key, this.recetaSeleccionada}) : super(key: key);

  @override
  _DetalleRecetaScreenState createState() => _DetalleRecetaScreenState();
}

class _DetalleRecetaScreenState extends State<DetalleRecetaScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  dynamic _recetaSeleccionada;
  Map<String, dynamic> _creatorData = {};
  List<dynamic> _comments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (widget.recetaSeleccionada != null) {
      _recetaSeleccionada = widget.recetaSeleccionada;
      _loadCreatorData(_recetaSeleccionada['id_usuario']);
      _loadComments(_recetaSeleccionada['id_receta']);
    }
  }

  // Simulación de carga de datos del creador
  Future<void> _loadCreatorData(String idUsuario) async {
    // Aquí iría tu lógica real de carga de datos
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _creatorData = {
        'nombre': 'Usuario $idUsuario',
        'avatar': null,
      };
    });
  }

  // Simulación de carga de comentarios
  Future<void> _loadComments(String idReceta) async {
    // Aquí iría tu lógica real de carga de comentarios
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _comments = [
        {'usuario': 'Ana', 'comentario': '¡Me encantó!'},
        {'usuario': 'Luis', 'comentario': 'Muy buena receta.'},
      ];
    });
  }

  void _onSelectReceta(dynamic receta) {
    setState(() {
      _recetaSeleccionada = receta;
      _tabController = TabController(length: 3, vsync: this);
      _creatorData = {};
      _comments = [];
    });
    _loadCreatorData(receta['id_usuario']);
    _loadComments(receta['id_receta']);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildDetalle() {
    if (_recetaSeleccionada == null) {
      return Center(child: Text('Selecciona una receta'));
    }
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            child: _creatorData['avatar'] != null
                ? Image.network(_creatorData['avatar'])
                : Icon(Icons.person),
          ),
          title: Text(_creatorData['nombre'] ?? 'Cargando...'),
          subtitle: Text('Creador'),
        ),
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Ingredientes'),
            Tab(text: 'Preparación'),
            Tab(text: 'Comentarios'),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildIngredientes(),
              _buildPreparacion(),
              _buildComentarios(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientes() {
    final ingredientes = _recetaSeleccionada['ingredientes'] ?? [];
    return ListView.builder(
      itemCount: ingredientes.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(ingredientes[index]),
        );
      },
    );
  }

  Widget _buildPreparacion() {
    final pasos = _recetaSeleccionada['preparacion'] ?? [];
    return ListView.builder(
      itemCount: pasos.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(pasos[index]),
        );
      },
    );
  }

  Widget _buildComentarios() {
    if (_comments.isEmpty) {
      return Center(child: Text('Sin comentarios'));
    }
    return ListView.builder(
      itemCount: _comments.length,
      itemBuilder: (context, index) {
        final comentario = _comments[index];
        return ListTile(
          leading: Icon(Icons.comment),
          title: Text(comentario['usuario']),
          subtitle: Text(comentario['comentario']),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de Receta'),
      ),
      body: _buildDetalle(),
    );
  }
}