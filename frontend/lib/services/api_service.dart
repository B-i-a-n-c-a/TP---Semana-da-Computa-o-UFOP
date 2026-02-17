import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Para Chrome/Web use localhost, para dispositivo físico use o IP da máquina
  static const String baseUrl = 'http://127.0.0.1:8000';

  // ===================== ALUNO =====================

  static Future<Map<String, dynamic>> criarAluno({
    required String nome,
    required String email,
    required String cpf,
    required String matricula,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/alunos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'email': email,
        'cpf': cpf,
        'matricula': matricula,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(jsonDecode(response.body)['detail'] ?? 'Erro ao criar aluno');
    }
  }

  static Future<List<dynamic>> listarAlunos() async {
    final response = await http.get(Uri.parse('$baseUrl/alunos'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao listar alunos');
    }
  }

  // ===================== PALESTRANTE =====================

  static Future<Map<String, dynamic>> criarPalestrante({
    required String nome,
    required String formacao,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/palestrantes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': nome,
        'formacao': formacao,
      }),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Erro ao criar palestrante');
    }
  }

  static Future<List<dynamic>> listarPalestrantes() async {
    final response = await http.get(Uri.parse('$baseUrl/palestrantes'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao listar palestrantes');
    }
  }

  // ===================== PALESTRA =====================

  static Future<Map<String, dynamic>> criarPalestra({
    required String titulo,
    required String horarioInicio,
    required String horarioFim,
    required String local,
    required int idPalestrante,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/palestras'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'titulo': titulo,
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

  static Future<List<dynamic>> listarPalestras() async {
    final response = await http.get(Uri.parse('$baseUrl/palestras'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erro ao listar palestras');
    }
  }

  // ===================== CHECK-IN =====================

  static Future<Map<String, dynamic>> fazerCheckin({
    required int idAluno,
    required int idPalestra,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/checkin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id_aluno': idAluno,
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

  // ===================== CERTIFICADO =====================

  static Future<Map<String, dynamic>> emitirCertificado(int idAluno) async {
    final response =
        await http.get(Uri.parse('$baseUrl/certificado/$idAluno'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          jsonDecode(response.body)['detail'] ?? 'Erro ao emitir certificado');
    }
  }
}
