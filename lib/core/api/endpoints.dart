// lib/core/api/endpoints.dart

class Endpoints {
  // Rotas de Autenticação e Usuário
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';

  static const String authRequestOtp = '/auth/request-otp';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authResetPassword = '/auth/reset-password';

  static const String authRefreshToken = '/auth/refresh';

  // Rotas de Gestão de Imóveis (CRUD)
  static const String imoveisList = '/imoveis';
  static const String imoveisRegister = '/imoveis/register';
  static const String imoveisGetDetail = '/imoveis/';
  static const String imoveisUpdate = '/imoveis/update';
  static const String imoveisSearch = '/imoveis/search';

  // Rotas de Proprietários
  static const String proprietariosList = '/proprietarios';
  static const String proprietarioUpdate = '/proprietarios/update';

  // Rotas de Adquirentes
  static const String adquirentesList = '/adquirentes';
  static const String adquirentesUpdate = '/adquirentes/update';

  // Rotas de usuario (f)
  static const String usuarioCadastro = '/usuario/cadastro';
  static const String usuarioTelefone = '/usuario/telefones';
  static const String usuarioDeleta = '/usuario/deleta';
  static const String usuarioPerfisImoveis = '/usuario/perfis-imoveis';
  static const String usuarioImoveisProprietario =
      '/usuario/imoveis-proprietario';
  static const String userUpdateProfile = '/usuario/perfil/update';
  static const String userUploadPicture = '/usuario/upload_foto_perfil';

  // Rotas de Pagamentos (f)
  static const String pagamentosCadastro = '/pagamentos/cadastro';
  static const String pagamentosStatus = '/pagamentos/status';
  static const String pagamentosAtualizaStatus = '/pagamentos/atualiza_status';
  static const String pagamentosExtratoImovel = '/pagamentos/extrato-imovel';
  static const String pagamentosExtratoAdquirente =
      '/pagamentos/extrato-adquirente';

  // Rotas de contrato (f)
  static const String contratoPrazo = '/contratos/prazo';
  static const String contratoCadastro = '/contratos/cadastro';
  static const String contratoDeletar = '/contratos/deleta';
  static const String contratoAlterarStatus = '/contratos/alterar-status';
  static const String contratoObterPeriodoAluguel =
      '/contratos/obter-periodo-aluguel';
  static const String contratoAluguelAtivo = '/contratos/alugueis-ativos';
  static const String contratoValoresImovel = '/contratos/obter-valores-imovel';
  static const String contratoMaisAlugados = '/contratos/obter-mais-alugados';
  static const String contratoPessoasImovel = '/contratos/obter-pessoas-imovel';

  // ❌ REMOVER: Esta rota não é um endpoint, mas o prefixo do Blueprint.
  // static const String auth = '/auth';
}
