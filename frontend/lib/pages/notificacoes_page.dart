import 'package:flutter/material.dart';
import '../services/api_service.dart';

class NotificacoesPage extends StatefulWidget {
  const NotificacoesPage({super.key});

  @override
  State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  List<dynamic> _notificacoes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _carregarNotificacoes();
  }

  Future<void> _carregarNotificacoes() async {
    setState(() => _loading = true);
    try {
      final notificacoes = await ApiService.listarNotificacoes();
      setState(() => _notificacoes = notificacoes);
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

  Future<void> _marcarComoLida(int idNotificacao, int index) async {
    try {
      await ApiService.marcarNotificacaoLida(idNotificacao);
      setState(() {
        _notificacoes[index]['lida'] = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarNotificacoes,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _notificacoes.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off,
                          size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Nenhuma notificação',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notificacoes.length,
                  itemBuilder: (context, index) {
                    final n = _notificacoes[index];
                    final lida = n['lida'] == true;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: lida ? null : Colors.blue.shade50,
                      elevation: lida ? 1 : 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: lida
                            ? BorderSide.none
                            : const BorderSide(
                                color: Colors.blue, width: 1),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: lida
                              ? Colors.grey.shade200
                              : Colors.blue.shade100,
                          child: Icon(
                            lida
                                ? Icons.notifications_none
                                : Icons.notifications_active,
                            color: lida ? Colors.grey : Colors.blue,
                          ),
                        ),
                        title: Text(
                          n['titulo'] ?? '',
                          style: TextStyle(
                            fontWeight:
                                lida ? FontWeight.normal : FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(n['mensagem'] ?? ''),
                        trailing: lida
                            ? const Icon(Icons.check,
                                color: Colors.green, size: 20)
                            : TextButton(
                                onPressed: () => _marcarComoLida(
                                    n['id_notificacao'], index),
                                child: const Text('Lida'),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}
