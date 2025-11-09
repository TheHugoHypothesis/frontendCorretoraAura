import 'dart:io';
import 'package:aura_frontend/data/models/corretor_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/services.dart';

import '../../data/mocks/especialidades_mock.dart';
import '../../data/mocks/bairros_atuacao_mock.dart';

// ----------------------- COMPONENTES DE INTERFACE -----------------------

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
        Text(title, style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
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

// ----------------------- PÁGINA PRINCIPAL -----------------------

class CorretorProfilePage extends StatefulWidget {
  final CorretorModel corretor;

  const CorretorProfilePage({super.key, required this.corretor});

  @override
  State<CorretorProfilePage> createState() => _CorretorProfilePageState();
}

class _CorretorProfilePageState extends State<CorretorProfilePage> {
  late TextEditingController _prenomeController;
  late TextEditingController _sobrenomeController;
  late TextEditingController _emailController;

  late String _especialidadeSelecionada;
  late String _regiaoAtuacaoSelecionada;

  // Telefones (até 3)
  final List<TextEditingController> _telefoneControllers = [];

  // Imagem
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  final phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );

  @override
  void initState() {
    super.initState();

    _prenomeController = TextEditingController(text: widget.corretor.prenome);
    _sobrenomeController = TextEditingController(text: widget.corretor.sobrenome);
    _emailController = TextEditingController(text: widget.corretor.email);

    // Telefones
    final telefones = widget.corretor.telefone.split(',').map((t) => t.trim()).toList();
    if (telefones.isEmpty) telefones.add('');
    for (var t in telefones) {
      _telefoneControllers.add(TextEditingController(text: t));
    }

    _especialidadeSelecionada = widget.corretor.especialidade;
    _regiaoAtuacaoSelecionada = widget.corretor.regiaoAtuacao;
  }

  @override
  void dispose() {
    _prenomeController.dispose();
    _sobrenomeController.dispose();
    _emailController.dispose();
    for (final c in _telefoneControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addTelefone() {
    if (_telefoneControllers.length < 3) {
      setState(() {
        _telefoneControllers.add(TextEditingController());
      });
    }
  }

  void _removeTelefone(int index) {
    if (_telefoneControllers.length > 1) {
      setState(() {
        _telefoneControllers.removeAt(index);
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  void _saveProfileChanges() {
    final telefones = _telefoneControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).join(', ');
    debugPrint('Telefones: $telefones');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
    );
  }

  void _logout() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  void _showPicker(List<String> items, String currentValue, Function(String) onSelected) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            magnification: 1.22,
            squeeze: 1.2,
            useMagnifier: true,
            itemExtent: 32.0,
            scrollController: FixedExtentScrollController(
              initialItem: items.indexOf(currentValue),
            ),
            onSelectedItemChanged: (int index) => onSelected(items[index]),
            children: List<Widget>.generate(items.length, (int index) {
              return Center(child: Text(items[index]));
            }),
          ),
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

    final String cpfDisplay = widget.corretor.cpf;
    final String creciDisplay = widget.corretor.creci;
    final String dataNascimentoDisplay = widget.corretor.dataNascimento;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text("Meu Perfil",
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                )),
            backgroundColor: isDark ? Colors.black : Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.0)),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _saveProfileChanges,
              child: Text("Salvar",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FOTO
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
                              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                            ),
                            child: ClipOval(
                              child: _profileImage != null
                                  ? Image.file(_profileImage!, fit: BoxFit.cover)
                                  : Icon(CupertinoIcons.person_alt_circle_fill,
                                      size: 100, color: Colors.grey.shade500),
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
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: Icon(CupertinoIcons.camera_fill,
                                  color: isDark ? Colors.black : Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // INFORMAÇÕES PESSOAIS
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

                  // LISTA DE TELEFONES
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._telefoneControllers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final controller = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: _buildTextField(
                            controller: controller,
                            hintText: "Telefone ${index + 1}",
                            icon: CupertinoIcons.phone_fill,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [phoneMaskFormatter],
                            theme: theme,
                            fieldColor: fieldColor,
                            primaryColor: primaryColor,
                            suffixIcon: _telefoneControllers.length > 1
                                ? GestureDetector(
                                    onTap: () => _removeTelefone(index),
                                    child: const Icon(CupertinoIcons.xmark_circle_fill,
                                        color: Colors.red, size: 22),
                                  )
                                : null,
                          ),
                        );
                      }),

                      // Botão adicionar telefone
                      if (_telefoneControllers.length < 3)
                        Align(
                          alignment: Alignment.centerRight,
                          child: CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: _addTelefone,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(CupertinoIcons.plus_circle_fill, color: Color.fromARGB(255, 0, 0, 0)),
                                SizedBox(width: 6),
                                Text("Adicionar telefone"),
                              ],
                            ),
                          ),
                        ),
                    ],
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

                  // OUTRAS SEÇÕES (igual ao original)
                  _buildSectionHeader(theme, "Atuação Profissional"),
                  const SizedBox(height: 16),
                  _buildProfileInfoTile(theme: theme, title: "CPF", value: cpfDisplay, primaryColor: primaryColor),
                  _buildProfileInfoTile(theme: theme, title: "CRECI", value: creciDisplay, primaryColor: primaryColor),
                  _buildProfileInfoTile(theme: theme, title: "Nascimento", value: dataNascimentoDisplay, primaryColor: primaryColor),

                  const SizedBox(height: 40),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
