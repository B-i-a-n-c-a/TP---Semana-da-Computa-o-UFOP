import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CadastroPalestrantePage extends StatefulWidget {
  const CadastroPalestrantePage({super.key});

  @override
  State<CadastroPalestrantePage> createState() =>
      _CadastroPalestrantePageState();
}

class _CadastroPalestrantePageState extends State<CadastroPalestrantePage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _formacaoController = TextEditingController();
  bool _loading = false;

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ApiService.criarPalestrante(
        nome: _nomeController.text.trim(),
        formacao: _formacaoController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Palestrante cadastrado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _nomeController.clear();
        _formacaoController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _formacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Palestrante'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.record_voice_over,
                  size: 64, color: Colors.deepPurple),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  labelText: 'Nome completo',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _formacaoController,
                decoration: const InputDecoration(
                  labelText: 'Formação',
                  prefixIcon: Icon(Icons.school),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Informe a formação'
                    : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _cadastrar,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                      _loading ? 'Cadastrando...' : 'Cadastrar Palestrante'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
