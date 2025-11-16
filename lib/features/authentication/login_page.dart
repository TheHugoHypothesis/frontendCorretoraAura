import 'package:aura_frontend/core/repositorios/authentication_repository.dart';
import 'package:aura_frontend/features/authentication/forgot_password_page.dart';
import 'package:aura_frontend/features/home/home_page.dart';
import 'package:aura_frontend/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

// ⚠️ Assumindo que este widget auxiliar está definido ou acessível.
Widget _buildTextField({
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  required ThemeData theme,
  required Color fieldColor,
  required Color primaryColor,
  Widget? suffixIcon,
  bool obscureText = false,
  TextInputType keyboardType =
      TextInputType.text, // Adicionado para flexibilidade
  List<TextInputFormatter>? inputFormatters, // Adicionado para flexibilidade
}) {
  final isDark = theme.brightness == Brightness.dark;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: fieldColor,
      borderRadius: BorderRadius.circular(14), // Bordas arredondadas
      border: Border.all(
        color: theme.brightness == Brightness.dark
            ? Colors.white12
            : Colors.grey.shade300,
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Icon(icon, color: primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType, // Usando o parâmetro
            inputFormatters: inputFormatters, // Usando o parâmetro
            style: theme.textTheme.bodyLarge?.copyWith(color: primaryColor),
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade500
                    : Colors.grey.shade600,
              ),
            ),
          ),
        ),
        if (suffixIcon != null) suffixIcon,
      ],
    ),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para os campos de texto
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final AuthenticationRepository _authRepository = AuthenticationRepository();
  bool _isLoading = false; // 👈 Estado de Carregamento

  var cpfMaskFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##', // Máscara XXX.XXX.XXX-XX
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  // Variável para controlar a visibilidade da senha
  bool _isPasswordVisible = false;

  void _handleLogin() async {
    if (_isLoading) return;

    final password = _passwordController.text;
    final rawCpf = cpfMaskFormatter.getUnmaskedText();

    if (rawCpf.length != 11 || password.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (context) => const CupertinoAlertDialog(
          title: Text("Dados Incompletos"),
          content: Text("Por favor, verifique seu CPF e Senha."),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final corretor = await _authRepository.login(rawCpf, password);

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.home,
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage;

        if (e.toString().contains("Exception:")) {
          errorMessage = e.toString().split("Exception:")[1].trim();
        } else {
          errorMessage = "Falha de comunicação com o servidor.";
        }

        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Falha no Login"),
            content: Text(errorMessage),
            actions: [
              CupertinoDialogAction(
                  child: const Text("OK"),
                  onPressed: () => Navigator.pop(context)),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleMissPassword() {
    Navigator.pushNamed(context, AppRoutes.forgotPassword);
  }

  void _navigateToSignUp() {
    Navigator.pushNamed(context, AppRoutes.signUp);
  }

  // NOVO WIDGET: Botão de Cadastro Secundário
  Widget _buildSignUpButton(ThemeData theme, Color primaryColor) {
    return Center(
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: _navigateToSignUp,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Não tem conta? ",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            Text(
              "Cadastre-se",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final secondaryColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;
    final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          // Column é o container principal para empilhar itens verticalmente
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. BOTÃO DE VOLTAR (Navigation Bar Simulada)
            Padding(
              padding: const EdgeInsets.only(left: 10.0, top: 10.0),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () =>
                    Navigator.pop(context), // Volta para a OnboardingPage
                child: Icon(CupertinoIcons.back, color: primaryColor),
              ),
            ),

            // 2. CONTEÚDO PRINCIPAL (Expanded para ocupar o espaço restante)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Espaçamento ajustado para não ficar muito grudado no topo
                    const SizedBox(height: 30),

                    // Título "Apple Like"
                    Text(
                      "Aura\nImobiliária",
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: primaryColor,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      "Bem-vindo(a) de volta, corretor.",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: secondaryColor,
                      ),
                    ),

                    const SizedBox(height: 60),

                    // Campo de CPF
                    _buildTextField(
                      controller: _cpfController, // Usando o controlador de CPF
                      hintText: "CPF", // Alterado o hint
                      icon: CupertinoIcons.person_fill,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor,
                      keyboardType: TextInputType
                          .number, // Alterado para teclado numérico
                      inputFormatters: [
                        cpfMaskFormatter
                      ], // Aplicando a máscara
                    ),
                    const SizedBox(height: 16),

                    // Campo de Senha
                    _buildTextField(
                      controller: _passwordController,
                      hintText: "Senha",
                      icon: CupertinoIcons.lock_fill,
                      obscureText: !_isPasswordVisible,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? CupertinoIcons.eye_slash_fill
                              : CupertinoIcons.eye_fill,
                          color: secondaryColor,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Botão Esqueceu a Senha
                    Align(
                      alignment: Alignment.centerRight,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: _handleMissPassword,
                        child: Text(
                          "Esqueceu a senha?",
                          style: theme.textTheme.bodyMedium?.copyWith(
                              color: primaryColor, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),

                    const Spacer(), // Empurra o conteúdo para cima

                    // Botão de Login (Principal)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: CupertinoButton(
                        color: primaryColor,
                        onPressed: _isLoading
                            ? null
                            : _handleLogin, // Desabilita durante o loading
                        borderRadius: BorderRadius.circular(14),
                        child: _isLoading
                            ? const CupertinoActivityIndicator(
                                color: Colors.white) // Indicador
                            : Text(
                                "Entrar",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: backgroundColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16), // Espaçamento entre botões

                    // Botão de Cadastro (Secundário, Estilo Texto)
                    _buildSignUpButton(theme, primaryColor),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
