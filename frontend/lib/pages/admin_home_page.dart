import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_page.dart';
import 'cadastro_palestrante_page.dart';
import 'cadastro_palestra_page.dart';
import 'certificado_page.dart';
import 'gerenciar_admins_page.dart';
import 'enviar_notificacao_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  void _logout(BuildContext context) async {
    await ApiService.logout();
    if (context.mounted) {
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
        title: const Text('Painel do Administrador'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.admin_panel_settings,
                size: 80, color: Colors.deepPurple),
            const SizedBox(height: 8),
            const Text(
              'Área Administrativa',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Semana da Computação — DECSI/UFOP',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _MenuCard(
              icon: Icons.record_voice_over,
              title: 'Cadastrar Palestrante',
              subtitle: 'Registrar palestrante do evento',
              color: Colors.orange,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CadastroPalestrantePage()),
              ),
            ),
            _MenuCard(
              icon: Icons.event,
              title: 'Cadastrar Palestra',
              subtitle: 'Criar nova palestra no evento',
              color: Colors.teal,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CadastroPalestraPage()),
              ),
            ),
            _MenuCard(
              icon: Icons.workspace_premium,
              title: 'Emitir Certificado',
              subtitle: 'Gerar certificado para participante',
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CertificadoPage()),
              ),
            ),
            _MenuCard(
              icon: Icons.people,
              title: 'Gerenciar Administradores',
              subtitle: 'Adicionar ou remover admins',
              color: Colors.red,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const GerenciarAdminsPage()),
              ),
            ),
            _MenuCard(
              icon: Icons.notifications_active,
              title: 'Enviar Notificação',
              subtitle: 'Notificar usuários sobre atividades',
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const EnviarNotificacaoPage()),
              ),
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
