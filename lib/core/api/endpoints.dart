class Endpoints {
  // Rotas de Autenticação e Usuário
  static const String authLogin = '/auth/login';
  static const String authRegister = '/users/register';
  static const String authRequestOtp = '/auth/request-otp';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authResetPassword = '/auth/reset-password';
  static const String userUpdateProfile = '/users/profile/update';

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

  // Rotas de Contratos
  static const String contratosList = '/contratos';
  static const String contratoRegister = '/contratos/register';
  static const String contratoGetDetail = '/contratos/';

  // Rotas de Pagamentos
  static const String pagamentosList = '/pagamentos';
  static const String pagamentosRegister = '/pagamentos/register';

  static const String auth = '/auth';
}
