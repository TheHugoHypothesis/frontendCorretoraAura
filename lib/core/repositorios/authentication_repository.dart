// lib/core/repositories/authentication_repository.dart

import '../api/api_client.dart';
import '../api/endpoints.dart';
import '../api/token_manager.dart';
import '../../data/models/corretor_model.dart';

class AuthenticationRepository {
  final ApiClient _apiClient = ApiClient();

  // LOGIN
  Future<CorretorModel> login(String cpf, String password) async {
    final responseData = await _apiClient.post(
      Endpoints.authLogin,
      {'cpf': cpf, 'password': password},
    );

    // Salva os tokens localmente (JWT access + refresh)
    await TokenManager.saveTokens(
      responseData['access_token'],
      responseData['refresh_token'],
    );

    // Mapeia o usuário retornado
    try {
      final user = responseData['user'];
      return CorretorModel(
        prenome: user['prenome'],
        sobrenome: user['sobrenome'],
        cpf: cpf,
        email: user['email'],
        telefone: user['telefone'],
        dataNascimento: user['dataNascimento'],
        creci: user['creci'],
        especialidade: user['especialidade'],
        regiaoAtuacao: user['regiaoAtuacao'],
      );
    } catch (e) {
      throw Exception("Erro ao mapear dados do corretor: $e");
    }
  }

  /// LOGOUT
  Future<void> logout() async {
    await TokenManager.clearTokens();
  }

  /// CADASTRO
  Future<void> registerUser(Map<String, dynamic> userData) async {
    await _apiClient.post(
      Endpoints.authRegister,
      userData,
    );
  }

  /// SOLICITAR CÓDIGO OTP
  Future<void> requestOtp(String cpf) async {
    await _apiClient.post(
      Endpoints.authRequestOtp,
      {'cpf': cpf},
    );
  }

  /// VERIFICAR CÓDIGO OTP
  Future<void> verifyOtp(String cpf, String otpCode) async {
    await _apiClient.post(
      Endpoints.authVerifyOtp,
      {'cpf': cpf, 'otp_code': otpCode},
    );
  }

  /// RESETAR SENHA
  Future<void> resetPassword(
      String cpf, String otpCode, String newPassword) async {
    await _apiClient.post(
      Endpoints.authResetPassword,
      {
        'cpf': cpf,
        'otp_code': otpCode,
        'new_password': newPassword,
      },
    );
  }

  /// VERIFICAR SE EXISTE USUÁRIO LOGADO
  Future<bool> isLoggedIn() async {
    final token = await TokenManager.getAccessToken();
    return token != null;
  }

  /// RENOVAR TOKEN MANUALMENTE
  Future<bool> refreshSession() async {
    return await TokenManager.refreshAccessToken();
  }
}
