import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter/services.dart';

// Importe o widget auxiliar _buildTextField (Se estiver em um arquivo separado)
// Ex: import '../widgets/text_field_helper.dart';

// --- Widget Auxiliar Reutilizável (Placeholder, ajuste o import real) ---
// Note: Este widget deve estar acessível via import
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
            enabled: enabled, // Usando o parâmetro enabled
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

// --- WIDGET AUXILIAR: Tile de Informação Estática ---
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
// --- FIM DOS WIDGETS AUXILIARES ---

class CorretorProfilePage extends StatefulWidget {
  const CorretorProfilePage({super.key});

  @override
  State<CorretorProfilePage> createState() => _CorretorProfilePageState();
}

class _CorretorProfilePageState extends State<CorretorProfilePage> {
  // --- Atributos do Corretor (USUÁRIO + CORRETOR) ---
  final TextEditingController _prenomeController =
      TextEditingController(text: 'João');
  final TextEditingController _sobrenomeController =
      TextEditingController(text: 'Silva');
  final TextEditingController _telefoneController =
      TextEditingController(text: '(11) 98765-4321');
  final TextEditingController _emailController =
      TextEditingController(text: 'joao.silva@aura.com');
  final TextEditingController _especialidadeController =
      TextEditingController(text: 'Residencial Luxo');
  final TextEditingController _regiaoAtuacaoController =
      TextEditingController(text: 'Itaim Bibi');

  // Dados Estáticos/Críticos (Geralmente não editáveis)
  final String _cpf = '123.456.789-00';
  final String _creci = 'CRECI/SP 12345-J';
  final String _dataNascimento = '01/01/1985';

  // Imagem de Perfil
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Formatador
  final phoneMaskFormatter = MaskTextInputFormatter(
      mask: '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

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

    // Simulação de feedback de salvamento
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perfil atualizado com sucesso!')),
    );
  }

  void _logout() {
    // TODO: Implementar a lógica de logout e navegação para LoginPage
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;
    final iconColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: primaryColor == Colors.black
          ? Colors.white
          : Colors.black, // Fundo principal
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

                  _buildTextField(
                    controller: _especialidadeController,
                    hintText: "Especialidade",
                    icon: CupertinoIcons.tag_fill,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _regiaoAtuacaoController,
                    hintText: "Região de Atuação (Bairro)",
                    icon: CupertinoIcons.location_solid,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),

                  const SizedBox(height: 30),

                  // --- SEÇÃO 4: DADOS CRÍTICOS (Apenas Leitura) ---
                  _buildSectionHeader(theme, "Dados Críticos"),
                  const SizedBox(height: 16),

                  // CPF (Apenas Leitura)
                  _buildProfileInfoTile(
                    theme: theme,
                    title: "CPF",
                    value: _cpf,
                    primaryColor: primaryColor,
                  ),
                  const Divider(color: Colors.grey, height: 1),

                  // CRECI (Apenas Leitura)
                  _buildProfileInfoTile(
                    theme: theme,
                    title: "CRECI",
                    value: _creci,
                    primaryColor: primaryColor,
                  ),
                  const Divider(color: Colors.grey, height: 1),

                  // Data de Nascimento (Apenas Leitura)
                  _buildProfileInfoTile(
                    theme: theme,
                    title: "Nascimento",
                    value: _dataNascimento,
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

  // Widget Auxiliar para cabeçalhos de Seção
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
}
