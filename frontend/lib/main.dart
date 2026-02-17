import 'package:flutter/material.dart';
import 'pages/cadastro_aluno_page.dart';
import 'pages/cadastro_palestrante_page.dart';
import 'pages/cadastro_palestra_page.dart';
import 'pages/checkin_page.dart';
import 'pages/certificado_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Semana da Computação DECSI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semana da Computação DECSI'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.computer, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 8),
            const Text(
              'Sistema de Gerenciamento',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Semana da Computação — DECSI/UFOP',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _MenuCard(
              icon: Icons.person_add,
              title: 'Cadastrar Aluno',
              subtitle: 'Registrar novo aluno no evento',
              color: Colors.blue,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CadastroAlunoPage()),
              ),
            ),
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
              icon: Icons.workspace_premium,
              title: 'Certificado',
              subtitle: 'Emitir certificado de participação',
              color: Colors.purple,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CertificadoPage()),
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
          title: Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(subtitle),
          trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400),
          onTap: onTap,
        ),
      ),
    );
  }
}
