import 'package:aura_frontend/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/services.dart';

// Este é o widget auxiliar do seu login, ele deve ser incluído neste arquivo
// ou importado se estiver em um arquivo separado para funcionar.
Widget _buildTextField(
    {required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required ThemeData theme,
    required Color fieldColor,
    required Color primaryColor,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: fieldColor,
      borderRadius: BorderRadius.circular(14),
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
            keyboardType: keyboardType,
            style: theme.textTheme.bodyLarge?.copyWith(color: primaryColor),
            inputFormatters: inputFormatters,
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
// Fim do _buildTextField (Certifique-se que está disponível/importado)

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Atributos Comuns (Usuário)
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _sobrenomeController = TextEditingController();
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Atributos de Subclasses
  final TextEditingController _pontuacaoCreditoController =
      TextEditingController(); // Adquirente
  final TextEditingController _creciController =
      TextEditingController(); // Corretor
  final TextEditingController _especialidadeController =
      TextEditingController(); // Corretor
  final TextEditingController _regiaoAtuacaoController =
      TextEditingController(); // Corretor

  // Formatador
  var phoneMaskFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####', // Máscara (XX) XXXXX-XXXX
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  var cpfMaskFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##', // Máscara XXX.XXX.XXX-XX
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  // Controles de Checkbox
  bool _isProprietario = false;
  bool _isAdquirente = false;
  bool _isCorretor = false;

  // Controle de visibilidade de senha
  bool _isPasswordVisible = false;

  // Variável para armazenar a data de nascimento
  DateTime _dataNascimento = DateTime(2000, 1, 1);

  void _handleSignUp() async {
    if (!_isProprietario && !_isAdquirente && !_isCorretor) {
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: const Text("Tipo de Usuário Ausente"),
          content: const Text(
              "Você deve se registrar como Proprietário, Adquirente ou Corretor."),
          actions: [
            CupertinoDialogAction(
              child: const Text("OK"),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    print("Simulação: Dados de cadastro prontos para envio.");

    final accepted =
        await Navigator.pushNamed(context, AppRoutes.privacyPolicy);

    if (mounted) {
      if (accepted == true) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Cadastro Concluído"),
            content: const Text(
                "Bem-vindo(a)! Sua conta foi criada e os Termos de Privacidade foram aceitos. Clique em 'OK' para ir para o Login."),
            actions: [
              CupertinoDialogAction(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.login, (route) => false);
                },
              ),
            ],
          ),
        );
      } else {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text("Recusa de Termos"),
            content: const Text(
                "O aceite da Política de Privacidade é necessário para finalizar o cadastro e usar o sistema."),
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
  }

  // Seletor de Data para o estilo Apple/Cupertino
  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: MediaQuery.of(context).copyWith().size.height / 3,
          color: CupertinoColors.white,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: _dataNascimento,
            onDateTimeChanged: (DateTime newDate) {
              setState(() {
                _dataNascimento = newDate;
              });
            },
          ),
        );
      },
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
      // Usamos um CustomScrollView para um cabeçalho fixo com scroll suave do conteúdo
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              "Criar Conta",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            backgroundColor: backgroundColor,
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade300,
                width: 0.0, // Fino, estilo Cupertino
              ),
            ),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: Icon(CupertinoIcons.chevron_left, color: primaryColor),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Seção de Atributos Comuns (USUÁRIO) ---
                  Text(
                    "Informações Pessoais",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _nomeController,
                    hintText: "Nome (Prenome)",
                    icon: CupertinoIcons.person_crop_circle_fill,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _sobrenomeController,
                    hintText: "Sobrenome",
                    icon: CupertinoIcons.person_crop_circle,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _cpfController,
                    hintText: "CPF", // NOVO HINT
                    icon: CupertinoIcons.number_circle_fill,
                    keyboardType: TextInputType.number,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                    // APLICANDO O FORMATTER DE CPF
                    inputFormatters: [cpfMaskFormatter],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _telefoneController,
                    hintText: "Telefone de Contato", // NOVO HINT
                    icon: CupertinoIcons.phone_fill,
                    keyboardType: TextInputType.phone,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                    // ADICIONANDO O FORMATTER
                    inputFormatters: [phoneMaskFormatter],
                  ),
                  const SizedBox(height: 12),
                  // Campo de Data de Nascimento (Botão)
                  GestureDetector(
                    onTap: _showDatePicker,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: fieldColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.calendar,
                              color: primaryColor, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            "Data de Nascimento: ${_dataNascimento.toLocal().toString().split(' ')[0]}",
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- Seção de Acesso e Segurança ---
                  Text(
                    "Acesso e Segurança",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _emailController,
                    hintText: "E-mail",
                    icon: CupertinoIcons.mail_solid,
                    keyboardType: TextInputType.emailAddress,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
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

                  const SizedBox(height: 30),

                  // --- Seção de Tipos de Usuário (Checkboxes e Campos Dinâmicos) ---
                  Text(
                    "Como você irá atuar?",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Checkbox Proprietário
                  _buildCheckboxTile(
                    theme: theme,
                    title: "Proprietário",
                    subtitle: "Possui ou deseja vender/alugar imóveis.",
                    value: _isProprietario,
                    onChanged: (val) => setState(() => _isProprietario = val),
                  ),
                  const SizedBox(height: 12),

                  // Checkbox Adquirente
                  _buildCheckboxTile(
                    theme: theme,
                    title: "Adquirente",
                    subtitle:
                        "Deseja comprar ou alugar imóveis (Inquilino/Comprador).",
                    value: _isAdquirente,
                    onChanged: (val) => setState(() => _isAdquirente = val),
                  ),

                  // Campos Dinâmicos do Adquirente
                  if (_isAdquirente) ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _pontuacaoCreditoController,
                      hintText: "Pontuação de Crédito (Ex: 850)",
                      icon: CupertinoIcons.chart_bar_fill,
                      keyboardType: TextInputType.number,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor,
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Checkbox Corretor
                  _buildCheckboxTile(
                    theme: theme,
                    title: "Corretor",
                    subtitle: "Profissional que gerencia contratos.",
                    value: _isCorretor,
                    onChanged: (val) => setState(() => _isCorretor = val),
                  ),

                  // Campos Dinâmicos do Corretor
                  if (_isCorretor) ...[
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _creciController,
                      hintText: "Número CRECI (SP)",
                      icon: CupertinoIcons.square_stack_3d_up_fill,
                      keyboardType: TextInputType.text,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _especialidadeController,
                      hintText: "Especialidade (Ex: Residencial Luxo)",
                      icon: CupertinoIcons.tag_fill,
                      keyboardType: TextInputType.text,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _regiaoAtuacaoController,
                      hintText: "Região de Atuação (Bairro em SP)",
                      icon: CupertinoIcons.location_solid,
                      keyboardType: TextInputType.text,
                      theme: theme,
                      fieldColor: fieldColor,
                      primaryColor: primaryColor,
                    ),
                  ],

                  const SizedBox(height: 40),

                  // Botão de Cadastro
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: CupertinoButton(
                      color: primaryColor,
                      onPressed: _handleSignUp,
                      borderRadius: BorderRadius.circular(14),
                      child: Text(
                        "Criar Conta Aura",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: backgroundColor,
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
        ],
      ),
    );
  }

  // Widget para criar os Checkboxes no estilo iOS
  Widget _buildCheckboxTile({
    required ThemeData theme,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: primaryColor, // Preto ou Branco para o estilo B&W
            trackColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }
}
