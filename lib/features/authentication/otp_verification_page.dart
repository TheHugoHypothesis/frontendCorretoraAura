import 'package:aura_frontend/core/repositorios/authentication_repository.dart';
import 'package:aura_frontend/features/authentication/password_reset_page.dart';
import 'package:aura_frontend/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpVerificationPage extends StatefulWidget {
  final String cpf; // Recebe o CPF para exibir/referência

  const OtpVerificationPage({super.key, required this.cpf});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final int _otpLength = 6;
  // Controladores para cada dígito
  late List<TextEditingController> _otpControllers;
  // Foco para gerenciar a mudança entre campos
  late List<FocusNode> _focusNodes;

  // Estado para armazenar o código completo
  String _enteredOtp = '';

  final AuthenticationRepository _authRepository = AuthenticationRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _otpControllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());

    // Adiciona listener para avançar o foco automaticamente
    for (int i = 0; i < _otpLength; i++) {
      _otpControllers[i].addListener(() {
        if (_otpControllers[i].text.length == 1) {
          if (i < _otpLength - 1) {
            _focusNodes[i + 1].requestFocus();
          } else {
            _focusNodes[i].unfocus(); // Remove o foco do último campo
          }
        }
        _updateOtp();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _updateOtp() {
    _enteredOtp = _otpControllers.map((c) => c.text).join();
    setState(() {}); // Atualiza o botão para verificar se o OTP está completo
  }

  void _verifyOtp() async {
    if (_enteredOtp.length != _otpLength || _isLoading) return;

    // Remove o foco para garantir que o teclado desapareça
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      // 1. Chama o Repositório para verificar o OTP no backend
      await _authRepository.verifyOtp(
          widget.cpf, // CPF que veio da rota anterior
          _enteredOtp // Código OTP digitado
          );

      // 2. Se a chamada for bem-sucedida (status 200), navega para a redefinição de senha
      if (mounted) {
        final arguments = {
          'cpf': widget.cpf,
          'otpCode': _enteredOtp, // Passa o OTP validado para a próxima etapa
        };

        // Sucesso: Navega para a PasswordResetPage
        Navigator.pushNamed(
          context,
          AppRoutes.resetPassword,
          arguments: arguments,
        );
      }
    } catch (e) {
      // 3. Trata Erro (Ex: Código inválido ou expirado - 401/400)
      if (mounted) {
        String errorMessage = e.toString().contains("Exception:")
            ? e.toString().split("Exception:")[1].trim()
            : "Erro de comunicação. O código pode ter expirado.";

        _showAlert("Falha na Verificação", errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAlert(String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final accentColor = CupertinoColors.systemGrey;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: CupertinoNavigationBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Icon(CupertinoIcons.back, color: primaryColor),
        ),
        border: null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              Text(
                "Confirme o Código",
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Digite o código de 6 dígitos enviado para o seu e-mail.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: accentColor,
                ),
              ),

              const SizedBox(height: 40),

              // CAMPO DE ENTRADA OTP CENTRALIZADO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_otpLength, (index) {
                  return _buildOtpField(theme, index);
                }),
              ),

              const SizedBox(height: 30),

              // Botão Reenviar (Estilo Texto)
              Center(
                child: CupertinoButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Novo código enviado! (Mock)')),
                    );
                  },
                  child: Text("Reenviar código",
                      style: TextStyle(color: primaryColor)),
                ),
              ),

              const Spacer(),

              // Botão Verificar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: CupertinoButton(
                  color: primaryColor,
                  // Desabilita se o código não estiver completo OU estiver carregando
                  onPressed: (_enteredOtp.length == _otpLength && !_isLoading)
                      ? _verifyOtp
                      : null,
                  borderRadius: BorderRadius.circular(14),
                  child: _isLoading
                      ? const CupertinoActivityIndicator(
                          color: CupertinoColors.white)
                      : Text(
                          "Verificar",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para cada campo de dígito OTP
  Widget _buildOtpField(ThemeData theme, int index) {
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Container(
      width: 45,
      height: 55,
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _focusNodes[index].hasFocus ? primaryColor : Colors.transparent,
          width: 2,
        ),
      ),
      child: Center(
        child: CupertinoTextField(
          controller: _otpControllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: theme.textTheme.headlineSmall
              ?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
          cursorColor: primaryColor,
          decoration:
              const BoxDecoration(border: null), // Remove a borda padrão
          padding: EdgeInsets.zero,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            // Lógica para retroceder o foco automaticamente
            if (value.isEmpty && index > 0) {
              _focusNodes[index - 1].requestFocus();
            }
            _updateOtp();
          },
        ),
      ),
    );
  }
}
