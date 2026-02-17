import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CadastroPalestraPage extends StatefulWidget {
  const CadastroPalestraPage({super.key});

  @override
  State<CadastroPalestraPage> createState() => _CadastroPalestraPageState();
}

class _CadastroPalestraPageState extends State<CadastroPalestraPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _dataController = TextEditingController();
  final _horarioInicioController = TextEditingController();
  final _horarioFimController = TextEditingController();
  final _localController = TextEditingController();
  bool _loading = false;

  List<dynamic> _palestrantes = [];
  int? _palestranteSelecionado;

  @override
  void initState() {
    super.initState();
    _carregarPalestrantes();
  }

  Future<void> _carregarPalestrantes() async {
    try {
      final lista = await ApiService.listarPalestrantes();
      setState(() => _palestrantes = lista);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao carregar palestrantes: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _selecionarData() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final dia = picked.day.toString().padLeft(2, '0');
      final mes = picked.month.toString().padLeft(2, '0');
      final ano = picked.year.toString();
      _dataController.text = '$dia/$mes/$ano';
    }
  }

  Future<void> _selecionarHora(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hora = picked.hour.toString().padLeft(2, '0');
      final minuto = picked.minute.toString().padLeft(2, '0');
      controller.text = '$hora:$minuto';
    }
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_palestranteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecione um palestrante'),
            backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService.criarPalestra(
        titulo: _tituloController.text.trim(),
        data: _dataController.text.trim(),
        horarioInicio: _horarioInicioController.text.trim(),
        horarioFim: _horarioFimController.text.trim(),
        local: _localController.text.trim(),
        idPalestrante: _palestranteSelecionado!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Palestra cadastrada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        _tituloController.clear();
        _dataController.clear();
        _horarioInicioController.clear();
        _horarioFimController.clear();
        _localController.clear();
        setState(() => _palestranteSelecionado = null);
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
    _tituloController.dispose();
    _dataController.dispose();
    _horarioInicioController.dispose();
    _horarioFimController.dispose();
    _localController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Palestra'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.event, size: 64, color: Colors.deepPurple),
              const SizedBox(height: 24),
              TextFormField(
                controller: _tituloController,
                decoration: const InputDecoration(
                  labelText: 'Título da Palestra',
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o título' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dataController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Data',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                onTap: _selecionarData,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'Informe a data'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _horarioInicioController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Início',
                        prefixIcon: Icon(Icons.access_time),
                        border: OutlineInputBorder(),
                      ),
                      onTap: () => _selecionarHora(_horarioInicioController),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Informe o horário'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _horarioFimController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Fim',
                        prefixIcon: Icon(Icons.access_time_filled),
                        border: OutlineInputBorder(),
                      ),
                      onTap: () => _selecionarHora(_horarioFimController),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Informe o horário'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _localController,
                decoration: const InputDecoration(
                  labelText: 'Local',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Informe o local' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _palestranteSelecionado,
                decoration: const InputDecoration(
                  labelText: 'Palestrante',
                  prefixIcon: Icon(Icons.record_voice_over),
                  border: OutlineInputBorder(),
                ),
                items: _palestrantes.map<DropdownMenuItem<int>>((p) {
                  return DropdownMenuItem<int>(
                    value: p['id_palestrante'],
                    child: Text(p['nome'] ?? 'Sem nome'),
                  );
                }).toList(),
                onChanged: (v) =>
                    setState(() => _palestranteSelecionado = v),
                validator: (v) =>
                    v == null ? 'Selecione um palestrante' : null,
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _carregarPalestrantes,
                icon: const Icon(Icons.refresh),
                label: const Text('Atualizar lista de palestrantes'),
              ),
              const SizedBox(height: 16),
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
                      _loading ? 'Cadastrando...' : 'Cadastrar Palestra'),
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
