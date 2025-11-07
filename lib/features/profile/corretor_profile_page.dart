import 'dart:io';
import 'package:aura_frontend/data/models/corretor_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/services.dart';

import '../../data/mocks/especialidades_mock.dart';
import '../../data/mocks/bairros_atuacao_mock.dart';

Widget _buildSectionHeader(ThemeData theme, String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4.0),
    child: Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
    ),
  );
}

Widget _buildProfileInfoTile({
  required ThemeData theme,
  required String title,
  required String value,
  required Color primaryColor,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.grey,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: primaryColor,
          ),
        ),
      ],
    ),
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  required ThemeData theme,
  required Color fieldColor,
  required Color primaryColor,
  Widget? suffixIcon,
  bool obscureText = false,
  TextInputType keyboardType = TextInputType.text,
  List<TextInputFormatter>? inputFormatters,
  bool enabled = true,
}) {
  final isDark = theme.brightness == Brightness.dark;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
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
        Icon(icon, color: primaryColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
            enabled: enabled,
            style: theme.textTheme.bodyLarge?.copyWith(color: primaryColor),
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              ),
            ),
          ),
        ),
        if (suffixIcon != null) suffixIcon,
      ],
    ),
  );
}

class CorretorProfilePage extends StatefulWidget {
  final CorretorModel corretor;

  const CorretorProfilePage({super.key, required this.corretor});

  @override
  State<CorretorProfilePage> createState() => _CorretorProfilePageState();
}

class _CorretorProfilePageState extends State<CorretorProfilePage> {
  // --- Controladores (Inicializados com dados do widget) ---
  late TextEditingController _prenomeController;
  late TextEditingController _sobrenomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _emailController;

  late String _especialidadeSelecionada;
  late String _regiaoAtuacaoSelecionada;

  // Imagem de Perfil
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Formatador
  final phoneMaskFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  @override
  void initState() {
    super.initState();
    // Inicialização a partir do Model
    _prenomeController = TextEditingController(text: widget.corretor.prenome);
    _sobrenomeController =
        TextEditingController(text: widget.corretor.sobrenome);
    _telefoneController = TextEditingController(text: widget.corretor.telefone);
    _emailController = TextEditingController(text: widget.corretor.email);

    _especialidadeSelecionada = widget.corretor.especialidade;
    _regiaoAtuacaoSelecionada = widget.corretor.regiaoAtuacao;
  }

  @override
  void dispose() {
    _prenomeController.dispose();
    _sobrenomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // --- Funções de Perfil ---
  Future<void> _pickProfileImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  void _saveProfileChanges() {
    // TODO: Implementar a lógica de salvamento (API call)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
    );
  }

  void _logout() {
    // TODO: Implementar a lógica de logout e navegação para LoginPage
    // Pop até a primeira rota, que deve ser a LoginPage
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showPicker(
      List<String> items, String currentValue, Function(String) onSelected) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: 32.0,
            // Inicializa o picker na opção selecionada
            scrollController: FixedExtentScrollController(
              initialItem: items.indexOf(currentValue),
            ),
            onSelectedItemChanged: (int index) {
              onSelected(items[index]);
            },
            children: List<Widget>.generate(items.length, (int index) {
              return Center(child: Text(items[index]));
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorTile({
    required ThemeData theme,
    required String title,
    required String selectedValue,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final primaryColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final fieldColor = theme.brightness == Brightness.dark
        ? Colors.white10
        : Colors.grey.shade100;
    final accentColor = CupertinoColors.systemGrey;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: fieldColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(color: primaryColor),
              ),
            ),

            // Valor Selecionado
            Text(
              selectedValue,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 8),
            Icon(CupertinoIcons.chevron_right, color: accentColor, size: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

    // Acesso aos dados críticos
    final String cpfDisplay = widget.corretor.cpf;
    final String creciDisplay = widget.corretor.creci;
    final String dataNascimentoDisplay = widget.corretor.dataNascimento;

    return Scaffold(
      backgroundColor:
          primaryColor == Colors.black ? Colors.white : Colors.black,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              "Meu Perfil",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            backgroundColor: isDark ? Colors.black : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade300,
                width: 0.0,
              ),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _saveProfileChanges,
              child: Text(
                "Salvar",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SEÇÃO 1: FOTO DE PERFIL ---
                  Center(
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                            ),
                            child: ClipOval(
                              child: _profileImage != null
                                  ? Image.file(
                                      _profileImage!,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(
                                      CupertinoIcons.person_alt_circle_fill,
                                      size: 100,
                                      color: Colors.grey.shade500,
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(
                                CupertinoIcons.camera_fill,
                                color: isDark ? Colors.black : Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- SEÇÃO 2: INFORMAÇÕES PESSOAIS (Editáveis) ---
                  _buildSectionHeader(theme, "Informações Pessoais"),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _prenomeController,
                    hintText: "Prenome",
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
                    controller: _telefoneController,
                    hintText: "Telefone de Contato",
                    icon: CupertinoIcons.phone_fill,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [phoneMaskFormatter],
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _emailController,
                    hintText: "E-mail",
                    icon: CupertinoIcons.mail_solid,
                    keyboardType: TextInputType.emailAddress,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),

                  const SizedBox(height: 30),

                  // --- SEÇÃO 3: INFORMAÇÕES DO CORRETOR (Editáveis) ---
                  _buildSectionHeader(theme, "Atuação Profissional"),
                  const SizedBox(height: 16),

                  _buildSelectorTile(
                    theme: theme,
                    title: "Especialidade",
                    selectedValue: _especialidadeSelecionada,
                    icon: CupertinoIcons.tag_fill,
                    onTap: () => _showPicker(
                        especialidades,
                        _especialidadeSelecionada,
                        (newVal) =>
                            setState(() => _especialidadeSelecionada = newVal)),
                  ),
                  const SizedBox(height: 12),

                  // 2. SELETOR DE REGIÃO DE ATUAÇÃO
                  _buildSelectorTile(
                    theme: theme,
                    title: "Região de Atuação",
                    selectedValue: _regiaoAtuacaoSelecionada,
                    icon: CupertinoIcons.location_solid,
                    onTap: () => _showPicker(
                        bairrosAtuacao,
                        _regiaoAtuacaoSelecionada,
                        (newVal) =>
                            setState(() => _regiaoAtuacaoSelecionada = newVal)),
                  ),

                  const SizedBox(height: 30),

                  // --- SEÇÃO 4: DADOS CRÍTICOS (Apenas Leitura) ---
                  _buildSectionHeader(theme, "Dados Críticos"),
                  const SizedBox(height: 16),

                  // CPF (Apenas Leitura)
                  _buildProfileInfoTile(
                    theme: theme,
                    title: "CPF",
                    value: cpfDisplay,
                    primaryColor: primaryColor,
                  ),
                  const Divider(color: Colors.grey, height: 1),

                  // CRECI (Apenas Leitura)
                  _buildProfileInfoTile(
                    theme: theme,
                    title: "CRECI",
                    value: creciDisplay,
                    primaryColor: primaryColor,
                  ),
                  const Divider(color: Colors.grey, height: 1),

                  // Data de Nascimento (Apenas Leitura)
                  _buildProfileInfoTile(
                    theme: theme,
                    title: "Nascimento",
                    value: dataNascimentoDisplay,
                    primaryColor: primaryColor,
                  ),
                  const Divider(color: Colors.grey, height: 1),

                  const SizedBox(height: 40),

                  // --- SEÇÃO 5: LOGOUT ---
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: CupertinoButton(
                      color: Colors.red.shade600,
                      onPressed: _logout,
                      borderRadius: BorderRadius.circular(14),
                      child: Text(
                        "Sair da Conta",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
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
}
