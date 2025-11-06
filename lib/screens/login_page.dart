import 'package:aura_frontend/screens/home.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Importe a página de cadastro. Ajuste o nome da classe se for diferente de SignUpPage.
import 'package:aura_frontend/screens/cadastro_page.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controladores para os campos de texto
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variável para controlar a visibilidade da senha
  bool _isPasswordVisible = false;
  
  // Função de simulação de login
  void _handleLogin() {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isNotEmpty && password.isNotEmpty) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            const begin = Offset(0.0, 0.08);
            const end = Offset.zero;
            final curve = Curves.easeInOutCubic;
            final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: animation.drive(tween),
                child: child,
              ),
            );
          },
        ),
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Erro de Login"),
          content: const Text("Por favor, preencha todos os campos."),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  // NOVO: Função para navegar para a tela de Cadastro
  void _navigateToSignUp() {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => const SignUpPage(), // Usando 'SignUpPage' para consistência
        title: 'Criar Conta', 
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              
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

              // Campo de E-mail
              _buildTextField(
                controller: _emailController,
                hintText: "E-mail ou CPF",
                icon: CupertinoIcons.person_fill,
                theme: theme,
                fieldColor: fieldColor,
                primaryColor: primaryColor,
                // Ajustando o tipo de teclado para e-mail padrão
                keyboardType: TextInputType.emailAddress, 
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
                  onPressed: () {
                    // TODO: Implementar navegação para a tela de recuperação de senha
                  },
                  child: Text(
                    "Esqueceu a senha?",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w500
                    ),
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
                  onPressed: _handleLogin,
                  borderRadius: BorderRadius.circular(14), // Borda mais suave
                  child: Text(
                    "Entrar",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: backgroundColor, // Cor do texto invertida
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16), // Espaçamento entre botões

              // NOVO: Botão de Cadastro (Secundário, Estilo Texto)
              _buildSignUpButton(theme, primaryColor),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
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
}

// Widget auxiliar para construir os campos de texto no estilo "Apple Like"
Widget _buildTextField({
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  required ThemeData theme,
  required Color fieldColor,
  required Color primaryColor,
  Widget? suffixIcon,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text, // Adicionado para flexibilidade
  List<TextInputFormatter>? inputFormatters, // Adicionado para flexibilidade
}) {
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