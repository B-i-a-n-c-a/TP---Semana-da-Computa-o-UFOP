import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
  };

  // ===================== USUÁRIO LOCAL =====================

  static Future<void> salvarUsuario(Map<String, dynamic> usuario) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario', jsonEncode(usuario));
  }

  static Future<Map<String, dynamic>?> getUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('usuario');
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  static Future<int?> getUsuarioId() async {
    final usuario = await getUsuario();
    return usuario?['id_usuario'];
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('usuario');
  }

  // ===================== AUTH =====================

  static Future<Map<String, dynamic>> registro({
    required String nome,
    required String email,
    required String senha,
    String? cpf,
    String? matricula,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/registro'),
      headers: _headers,
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'senha': senha,
        'cpf': cpf,
        'matricula': matricula,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await salvarUsuario(data['usuario']);
      return data;
    } else {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Erro ao registrar');
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String senha,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'senha': senha}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await salvarUsuario(data['usuario']);
      return data;
    } else {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Erro ao fazer login');
    }
  }

  // ===================== ADMIN - PALESTRANTE =====================

  static Future<Map<String, dynamic>> criarPalestrante({
    required String nome,
    required String formacao,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/palestrantes'),
      headers: _headers,
      body: jsonEncode({'nome': nome, 'formacao': formacao}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Erro ao criar palestrante');
    }
  }

  static Future<List<dynamic>> listarPalestrantes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/palestrantes'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao listar palestrantes');
    }
  }

  // ===================== ADMIN - PALESTRA =====================

  static Future<Map<String, dynamic>> criarPalestra({
    required String titulo,
    String? descricao,
    required String data,
    required String horarioInicio,
    required String horarioFim,
    required String local,
    required int idPalestrante,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/palestras'),
      headers: _headers,
      body: jsonEncode({
        'titulo': titulo,
        'descricao': descricao,
        'data': data,
        'horario_inicio': horarioInicio,
        'horario_fim': horarioFim,
        'local': local,
        'id_palestrante': idPalestrante,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Erro ao criar palestra');
    }
  }

  // ===================== ADMIN - CERTIFICADO =====================

  static Future<Map<String, dynamic>> emitirCertificado(int idUsuario) async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/certificado/$idUsuario'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Erro ao emitir certificado');
    }
  }

  // ===================== ADMIN - ADMINISTRADORES =====================

  static Future<Map<String, dynamic>> criarAdmin({
    required String nome,
    required String email,
    required String senha,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/administradores'),
      headers: _headers,
      body: jsonEncode({'nome': nome, 'email': email, 'senha': senha}),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Erro ao criar admin');
    }
  }

  static Future<List<dynamic>> listarAdmins() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/administradores'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao listar admins');
    }
  }

  static Future<void> removerAdmin(int idUsuario) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/administradores/$idUsuario'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Erro ao remover admin');
    }
  }

  // ===================== ADMIN - LISTAR USUÁRIOS =====================

  static Future<List<dynamic>> listarUsuarios() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/usuarios'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao listar usuários');
    }
  }

  // ===================== ADMIN - NOTIFICAÇÕES =====================

  static Future<Map<String, dynamic>> enviarNotificacao({
    required String titulo,
    required String mensagem,
    int? idUsuario,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/notificacoes'),
      headers: _headers,
      body: jsonEncode({
        'titulo': titulo,
        'mensagem': mensagem,
        if (idUsuario != null) 'id_usuario': idUsuario,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Erro ao enviar notificação');
    }
  }

  // ===================== USUÁRIO - CRONOGRAMA =====================

  static Future<List<dynamic>> listarPalestrasPublicas() async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuario/palestras'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao listar palestras');
    }
  }

  // ===================== USUÁRIO - CHECK-IN =====================

  static Future<Map<String, dynamic>> fazerCheckin({
    required int idPalestra,
  }) async {
    final idUsuario = await getUsuarioId();
    final response = await http.post(
      Uri.parse('$baseUrl/usuario/checkin'),
      headers: _headers,
      body: jsonEncode({
        'id_usuario': idUsuario,
        'id_palestra': idPalestra,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Erro ao fazer check-in');
    }
  }

  static Future<List<dynamic>> listarMeusCheckins() async {
    final idUsuario = await getUsuarioId();
    final response = await http.get(
      Uri.parse('$baseUrl/usuario/checkins?id_usuario=$idUsuario'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao listar check-ins');
    }
  }

  // ===================== USUÁRIO - AVALIAÇÃO =====================

  static Future<Map<String, dynamic>> avaliarPalestra({
    required int idPalestra,
    required int nota,
    String? comentario,
  }) async {
    final idUsuario = await getUsuarioId();
    final response = await http.post(
      Uri.parse('$baseUrl/usuario/avaliar'),
      headers: _headers,
      body: jsonEncode({
        'id_usuario': idUsuario,
        'id_palestra': idPalestra,
        'nota': nota,
        'comentario': comentario,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Erro ao avaliar');
    }
  }

  static Future<List<dynamic>> listarAvaliacoesPorPalestra() async {
    final response = await http.get(
      Uri.parse('$baseUrl/usuario/avaliacoes-por-palestra'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao listar avaliações');
    }
  }

  // ===================== USUÁRIO - NOTIFICAÇÕES =====================

  static Future<List<dynamic>> listarNotificacoes() async {
    final idUsuario = await getUsuarioId();
    final response = await http.get(
      Uri.parse('$baseUrl/usuario/notificacoes?id_usuario=$idUsuario'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao listar notificações');
    }
  }

  static Future<void> marcarNotificacaoLida(int idNotificacao) async {
    final idUsuario = await getUsuarioId();
    final response = await http.put(
      Uri.parse(
          '$baseUrl/usuario/notificacoes/$idNotificacao/lida?id_usuario=$idUsuario'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Erro ao marcar notificação como lida');
    }
  }

  // ===================== USUÁRIO - MEU CERTIFICADO =====================

  static Future<Map<String, dynamic>> meuCertificado() async {
    final idUsuario = await getUsuarioId();
    final response = await http.get(
      Uri.parse('$baseUrl/usuario/meu-certificado?id_usuario=$idUsuario'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Erro ao buscar certificado');
    }
  }

  // ===================== USUÁRIO - PERFIL =====================

  static Future<Map<String, dynamic>> meuPerfil() async {
    final idUsuario = await getUsuarioId();
    final response = await http.get(
      Uri.parse('$baseUrl/usuario/perfil?id_usuario=$idUsuario'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao buscar perfil');
    }
  }

  // ===================== USUÁRIO - GERENCIAR CONTA =====================

  static Future<Map<String, dynamic>> alterarEmail({
    required String senhaAtual,
    required String novoEmail,
  }) async {
    final idUsuario = await getUsuarioId();
    final response = await http.put(
      Uri.parse('$baseUrl/usuario/alterar-email'),
      headers: _headers,
      body: jsonEncode({
        'id_usuario': idUsuario,
        'senha_atual': senhaAtual,
        'novo_email': novoEmail,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Atualiza os dados locais do usuário
      if (data['usuario'] != null) {
        await salvarUsuario(data['usuario']);
      }
      return data;
    } else {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Erro ao alterar email');
    }
  }

  static Future<Map<String, dynamic>> alterarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    final idUsuario = await getUsuarioId();
    final response = await http.put(
      Uri.parse('$baseUrl/usuario/alterar-senha'),
      headers: _headers,
      body: jsonEncode({
        'id_usuario': idUsuario,
        'senha_atual': senhaAtual,
        'nova_senha': novaSenha,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Erro ao alterar senha');
    }
  }

  static Future<Map<String, dynamic>> excluirConta({
    required String senhaAtual,
  }) async {
    final idUsuario = await getUsuarioId();
    final request = http.Request(
      'DELETE',
      Uri.parse('$baseUrl/usuario/excluir-conta'),
    );
    request.headers.addAll(_headers);
    request.body = jsonEncode({
      'id_usuario': idUsuario,
      'senha_atual': senhaAtual,
    });
    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode == 200) {
      await logout();
      return jsonDecode(response.body);
    } else {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Erro ao excluir conta');
    }
  }
}
