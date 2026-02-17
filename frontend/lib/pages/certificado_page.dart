import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CertificadoPage extends StatefulWidget {
  const CertificadoPage({super.key});

  @override
  State<CertificadoPage> createState() => _CertificadoPageState();
}

class _CertificadoPageState extends State<CertificadoPage> {
  List<dynamic> _alunos = [];
  int? _alunoSelecionado;
  Map<String, dynamic>? _certificado;
  bool _loading = false;
  bool _buscando = false;

  @override
  void initState() {
    super.initState();
    _carregarAlunos();
  }

  Future<void> _carregarAlunos() async {
    try {
      final alunos = await ApiService.listarAlunos();
      setState(() => _alunos = alunos);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao carregar alunos: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _emitirCertificado() async {
    if (_alunoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um aluno'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() {
      _buscando = true;
      _certificado = null;
    });
    try {
      final cert = await ApiService.emitirCertificado(_alunoSelecionado!);
      setState(() => _certificado = cert);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _buscando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emissão de Certificado'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.workspace_premium,
                size: 64, color: Colors.deepPurple),
            const SizedBox(height: 8),
            const Text(
              'Gerar certificado de participação',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<int>(
              value: _alunoSelecionado,
              decoration: const InputDecoration(
                labelText: 'Selecione o Aluno',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              items: _alunos.map<DropdownMenuItem<int>>((a) {
                return DropdownMenuItem<int>(
                  value: a['id_aluno'],
                  child: Text('${a['nome']} (${a['matricula']})'),
                );
              }).toList(),
              onChanged: (v) => setState(() {
                _alunoSelecionado = v;
                _certificado = null;
              }),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _buscando ? null : _emitirCertificado,
                icon: _buscando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.description),
                label: Text(
                    _buscando ? 'Gerando...' : 'Emitir Certificado'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            if (_certificado != null) ...[
              const SizedBox(height: 32),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: Colors.deepPurple, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.verified,
                          size: 48, color: Colors.deepPurple),
                      const SizedBox(height: 8),
                      const Text(
                        'CERTIFICADO DE PARTICIPAÇÃO',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Text(
                        'Semana da Computação DECSI',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const Divider(height: 32),
                      Text(
                        _certificado!['mensagem'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Palestras assistidas:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...(_certificado!['palestras'] as List).map((p) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${p['titulo']} — ${p['horario_inicio']} às ${p['horario_fim']} (${p['palestrante']})',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const Divider(height: 32),
                      Text(
                        'Total: ${_certificado!['total_horas']} horas',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Emitido em: ${_certificado!['data_emissao']}',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
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
