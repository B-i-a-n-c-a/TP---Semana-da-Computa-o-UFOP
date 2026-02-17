import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CheckinPage extends StatefulWidget {
  const CheckinPage({super.key});

  @override
  State<CheckinPage> createState() => _CheckinPageState();
}

class _CheckinPageState extends State<CheckinPage> {
  List<dynamic> _alunos = [];
  List<dynamic> _palestras = [];
  int? _alunoSelecionado;
  int? _palestraSelecionada;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final alunos = await ApiService.listarAlunos();
      final palestras = await ApiService.listarPalestras();
      setState(() {
        _alunos = alunos;
        _palestras = palestras;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao carregar dados: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _fazerCheckin() async {
    if (_alunoSelecionado == null || _palestraSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o aluno e a palestra'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      final resultado = await ApiService.fazerCheckin(
        idAluno: _alunoSelecionado!,
        idPalestra: _palestraSelecionada!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resultado['mensagem'] ?? 'Check-in realizado!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _alunoSelecionado = null;
          _palestraSelecionada = null;
        });
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarDados,
            tooltip: 'Atualizar listas',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.qr_code_scanner,
                size: 64, color: Colors.deepPurple),
            const SizedBox(height: 8),
            const Text(
              'Registrar presença do aluno em uma palestra',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            DropdownButtonFormField<int>(
              value: _alunoSelecionado,
              decoration: const InputDecoration(
                labelText: 'Aluno',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              items: _alunos.map<DropdownMenuItem<int>>((a) {
                return DropdownMenuItem<int>(
                  value: a['id_aluno'],
                  child: Text('${a['nome']} (${a['matricula']})'),
                );
              }).toList(),
              onChanged: (v) => setState(() => _alunoSelecionado = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: _palestraSelecionada,
              decoration: const InputDecoration(
                labelText: 'Palestra',
                prefixIcon: Icon(Icons.event),
                border: OutlineInputBorder(),
              ),
              items: _palestras.map<DropdownMenuItem<int>>((p) {
                return DropdownMenuItem<int>(
                  value: p['id_palestra'],
                  child: Text(
                      '${p['titulo']} (${p['horario_inicio']} - ${p['horario_fim']})'),
                );
              }).toList(),
              onChanged: (v) => setState(() => _palestraSelecionada = v),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _fazerCheckin,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_circle, size: 28),
                label: Text(
                  _loading ? 'Registrando...' : 'Confirmar Check-in',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
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
