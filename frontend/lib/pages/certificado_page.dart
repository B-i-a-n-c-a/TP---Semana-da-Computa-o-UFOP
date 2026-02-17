import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
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

  Future<void> _exportarPdf() async {
    if (_certificado == null) return;

    final pdf = pw.Document();
    final aluno = _certificado!['aluno'];
    final palestras = _certificado!['palestras'] as List;
    final totalHoras = _certificado!['total_horas'];
    final dataEmissao = _certificado!['data_emissao'];
    final mensagem = _certificado!['mensagem'] ?? '';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(
                color: PdfColor.fromHex('#7B1FA2'),
                width: 3,
              ),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'CERTIFICADO DE PARTICIPAÇÃO',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColor.fromHex('#7B1FA2'),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Semana da Computação — DECSI/UFOP',
                  style: pw.TextStyle(
                    fontSize: 16,
                    color: PdfColor.fromHex('#666666'),
                  ),
                ),
                pw.Divider(height: 40, color: PdfColor.fromHex('#7B1FA2')),
                pw.Text(
                  mensagem,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 16),
                ),
                pw.SizedBox(height: 24),
                pw.Align(
                  alignment: pw.Alignment.centerLeft,
                  child: pw.Text(
                    'Palestras assistidas:',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                ...palestras.map((p) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 3),
                    child: pw.Row(
                      children: [
                        pw.Text('✔  ',
                            style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColor.fromHex('#388E3C'))),
                        pw.Expanded(
                          child: pw.Text(
                            '${p['titulo']} — ${p['horario_inicio']} às ${p['horario_fim']} (${p['palestrante']})',
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                pw.Divider(height: 40, color: PdfColor.fromHex('#7B1FA2')),
                pw.Text(
                  'Carga horária total: $totalHoras horas',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Emitido em: $dataEmissao',
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: PdfColor.fromHex('#999999'),
                      ),
                    ),
                    pw.Column(
                      children: [
                        pw.Container(
                          width: 200,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              top: pw.BorderSide(width: 1),
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('Coordenação do Evento',
                            style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    final nomeAluno = aluno['nome'] ?? 'certificado';
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'certificado_$nomeAluno.pdf',
    );
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
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _exportarPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Exportar PDF'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
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
