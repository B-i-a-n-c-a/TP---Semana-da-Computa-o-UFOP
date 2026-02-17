import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EnviarNotificacaoPage extends StatefulWidget {
  const EnviarNotificacaoPage({super.key});

  @override
  State<EnviarNotificacaoPage> createState() => _EnviarNotificacaoPageState();
}

class _EnviarNotificacaoPageState extends State<EnviarNotificacaoPage> {
  final _tituloController = TextEditingController();
  final _mensagemController = TextEditingController();
  bool _loading = false;
  bool _paraTodos = true;

  List<dynamic> _usuarios = [];
  int? _usuarioSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarUsuarios();
  }

  Future<void> _carregarUsuarios() async {
    try {
      final usuarios = await ApiService.listarUsuarios();
      setState(() => _usuarios = usuarios);
    } catch (_) {}
  }

  Future<void> _enviar() async {
    if (_tituloController.text.trim().isEmpty ||
        _mensagemController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha título e mensagem'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    if (!_paraTodos && _usuarioSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um usuário'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ApiService.enviarNotificacao(
        titulo: _tituloController.text.trim(),
        mensagem: _mensagemController.text.trim(),
        idUsuario: _paraTodos ? null : _usuarioSelecionado,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificação enviada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _tituloController.clear();
        _mensagemController.clear();
        setState(() => _usuarioSelecionado = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _mensagemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Notificação'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.notifications_active,
                size: 64, color: Colors.blue),
            const SizedBox(height: 8),
            const Text(
              'Envie notificações para os participantes',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _mensagemController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Mensagem',
                prefixIcon: Icon(Icons.message),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enviar para todos os usuários'),
              value: _paraTodos,
              onChanged: (v) => setState(() => _paraTodos = v),
              activeColor: Colors.deepPurple,
            ),
            if (!_paraTodos) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _usuarioSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Selecionar Usuário',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                items: _usuarios.map<DropdownMenuItem<int>>((u) {
                  return DropdownMenuItem<int>(
                    value: u['id_usuario'],
                    child: Text('${u['nome']} (${u['email']})'),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _usuarioSelecionado = v),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _enviar,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.send),
                label: Text(_loading ? 'Enviando...' : 'Enviar Notificação'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
