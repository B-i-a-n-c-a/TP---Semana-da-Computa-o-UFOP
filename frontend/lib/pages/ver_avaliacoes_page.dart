import 'package:flutter/material.dart';
import '../services/api_service.dart';

class VerAvaliacoesPage extends StatefulWidget {
  const VerAvaliacoesPage({super.key});

  @override
  State<VerAvaliacoesPage> createState() => _VerAvaliacoesPageState();
}

class _VerAvaliacoesPageState extends State<VerAvaliacoesPage> {
  List<dynamic> _palestras = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarAvaliacoes();
  }

  Future<void> _carregarAvaliacoes() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.listarAvaliacoesPorPalestra();
      setState(() => _palestras = data);
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

  Widget _buildEstrelas(num nota) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < nota.round() ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avaliações por Palestra'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _palestras.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.rate_review_outlined,
                            size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma palestra cadastrada ainda.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _carregarAvaliacoes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _palestras.length,
                    itemBuilder: (context, index) {
                      final palestra = _palestras[index];
                      final avaliacoes =
                          palestra['avaliacoes'] as List<dynamic>;
                      final media = palestra['media_nota'] ?? 0;
                      final total = palestra['total_avaliacoes'] ?? 0;

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: total > 0
                                ? Colors.amber.shade100
                                : Colors.grey.shade200,
                            child: Icon(
                              total > 0
                                  ? Icons.star
                                  : Icons.star_border,
                              color: total > 0
                                  ? Colors.amber.shade700
                                  : Colors.grey,
                            ),
                          ),
                          title: Text(
                            palestra['titulo'] ?? 'Palestra',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Palestrante: ${palestra['palestrante'] ?? 'N/A'}',
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              ),
                              if (palestra['data'] != null)
                                Text(
                                  'Data: ${palestra['data']}',
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.grey),
                                ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  _buildEstrelas(media),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$media',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amber.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '($total avaliação${total != 1 ? 'ões' : ''})',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          children: [
                            if (avaliacoes.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text(
                                  'Nenhuma avaliação ainda.',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 14),
                                ),
                              )
                            else
                              ...avaliacoes.map((av) {
                                return ListTile(
                                  leading: CircleAvatar(
                                    radius: 18,
                                    backgroundColor:
                                        Colors.deepPurple.shade50,
                                    child: Text(
                                      '${av['nota']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple.shade700,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    av['nome_usuario'] ?? 'Anônimo',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildEstrelas(av['nota']),
                                      if (av['comentario'] != null &&
                                          av['comentario']
                                              .toString()
                                              .isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4),
                                          child: Text(
                                            '"${av['comentario']}"',
                                            style: const TextStyle(
                                              fontStyle: FontStyle.italic,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            const SizedBox(height: 8),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
