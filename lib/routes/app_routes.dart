class AppRoutes {
  static const String initial = '/'; // Geralmente a HomePage ou Login
  static const String onboarding = '/onboarding';

  // Rotas da Home/Navegação
  static const String home = '/home';
  static const String contracts = '/contracts';
  static const String payments = '/payments';
  static const String profile = '/profile';
  static const String perfilCorretor = '/perfil/corretor';

  static const String login = '/login';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String otpVerification = '/otp-verification';
  static const String privacyPolicy = '/policy';

  // Rotas de Fluxo (Push)
  static const String propertyRegistration = '/imovel/cadastro';
  static const String propertyDetails = '/imovel/detalhes';
  static const String propertyPerformance = '/imovel/performance';
  static const String filters = '/imovel/filtros';

  static const String gerenciamentoAdquirentes = 'gerenciamento/adquirentes';
  static const String gerenciamentoProprietarios =
      'gerenciamento/proprietarios';
}
