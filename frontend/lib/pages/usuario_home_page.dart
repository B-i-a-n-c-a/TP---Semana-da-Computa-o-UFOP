import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';
import 'checkin_page.dart';
import 'avaliacao_page.dart';
import 'cronograma_page.dart';
import 'notificacoes_page.dart';
import 'meu_certificado_page.dart';

class UsuarioHomePage extends StatefulWidget {
  const UsuarioHomePage({super.key});

  @override
  State<UsuarioHomePage> createState() => _UsuarioHomePageState();
}

class _UsuarioHomePageState extends State<UsuarioHomePage> {
  String _nomeUsuario = 'Usuário';
  int _notificacoesNaoLidas = 0;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final usuario = await ApiService.getUsuario();
      final notificacoes = await ApiService.listarNotificacoes();
      if (mounted) {
        setState(() {
          _nomeUsuario = usuario?['nome'] ?? 'Usuário';
          _notificacoesNaoLidas =
              notificacoes.where((n) => n['lida'] == false).length;
        });
      }
    } catch (_) {}
  }

  void _logout() async {
    await ApiService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semana da Computação'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                tooltip: 'Notificações',
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificacoesPage()),
                  );
                  _carregarDados();
                },
              ),
              if (_notificacoesNaoLidas > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$_notificacoesNaoLidas',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.person, size: 64, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              'Olá, $_nomeUsuario!',
              style:
                  const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'O que deseja fazer?',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _MenuCard(
              icon: Icons.calendar_month,
              title: 'Cronograma',
              subtitle: 'Ver palestras e horários',
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CronogramaPage()),
              ),
            ),
            _MenuCard(
              icon: Icons.qr_code_scanner,
              title: 'Check-in',
              subtitle: 'Registrar presença em palestra',
              color: Colors.green,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckinPage()),
              ),
            ),
            _MenuCard(
              icon: Icons.star_rate,
              title: 'Avaliar Palestra',
              subtitle: 'Avalie as palestras que assistiu',
              color: Colors.amber,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AvaliacaoPage()),
              ),
            ),
            _MenuCard(
              icon: Icons.workspace_premium,
              title: 'Meu Certificado',
              subtitle: 'Ver e exportar seu certificado',
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const MeuCertificadoPage()),
              ),
            ),
            _MenuCard(
              icon: Icons.notifications,
              title: 'Notificações',
              subtitle: _notificacoesNaoLidas > 0
                  ? '$_notificacoesNaoLidas novas notificações'
                  : 'Sem notificações novas',
              color: Colors.red,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificacoesPage()),
                );
                _carregarDados();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            radius: 24,
            child: Icon(icon, color: color, size: 28),
          ),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400),
          onTap: onTap,
        ),
      ),
    );
  }
}
