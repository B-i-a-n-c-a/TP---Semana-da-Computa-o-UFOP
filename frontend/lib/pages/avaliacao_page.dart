import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AvaliacaoPage extends StatefulWidget {
  const AvaliacaoPage({super.key});

  @override
  State<AvaliacaoPage> createState() => _AvaliacaoPageState();
}

class _AvaliacaoPageState extends State<AvaliacaoPage> {
  List<dynamic> _checkins = [];
  int? _palestraSelecionada;
  int _nota = 3;
  final _comentarioController = TextEditingController();
  bool _loading = false;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarCheckins();
  }

  Future<void> _carregarCheckins() async {
    setState(() => _carregando = true);
    try {
      final checkins = await ApiService.listarMeusCheckins();
      setState(() => _checkins = checkins);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _carregando = false);
    }
  }

  Future<void> _avaliar() async {
    if (_palestraSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione uma palestra'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final resultado = await ApiService.avaliarPalestra(
        idPalestra: _palestraSelecionada!,
        nota: _nota,
        comentario: _comentarioController.text.trim().isNotEmpty
            ? _comentarioController.text.trim()
            : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['mensagem'] ?? 'Avaliação registrada!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _palestraSelecionada = null;
          _nota = 3;
          _comentarioController.clear();
        });
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
    _comentarioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliar Palestra'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.star_rate,
                      size: 64, color: Colors.amber),
                  const SizedBox(height: 8),
                  const Text(
                    'Avalie uma palestra que você assistiu',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  if (_checkins.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Você ainda não fez check-in em nenhuma palestra.\n\nFaça check-in primeiro para poder avaliar.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ),
                    )
                  else ...[
                    DropdownButtonFormField<int>(
                      value: _palestraSelecionada,
                      decoration: const InputDecoration(
                        labelText: 'Palestra',
                        prefixIcon: Icon(Icons.event),
                        border: OutlineInputBorder(),
                      ),
                      items: _checkins.map<DropdownMenuItem<int>>((c) {
                        return DropdownMenuItem<int>(
                          value: c['id_palestra'],
                          child: Text(c['titulo_palestra'] ?? 'Palestra'),
                        );
                      }).toList(),
                      onChanged: (v) =>
                          setState(() => _palestraSelecionada = v),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Nota:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (i) {
                        final estrela = i + 1;
                        return IconButton(
                          iconSize: 40,
                          icon: Icon(
                            estrela <= _nota
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () =>
                              setState(() => _nota = estrela),
                        );
                      }),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _comentarioController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Comentário (opcional)',
                        prefixIcon: Icon(Icons.comment),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _avaliar,
                        icon: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Icon(Icons.send),
                        label: Text(_loading
                            ? 'Enviando...'
                            : 'Enviar Avaliação'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade700,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
