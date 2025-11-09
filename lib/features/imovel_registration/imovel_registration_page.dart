import 'package:aura_frontend/features/imovel_registration/map_location_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

import 'dart:io'; // Para o tipo File
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import 'package:aura_frontend/data/models/selected_location_model.dart';
import '../../utils/uppercase_text_formatter.dart';

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
  // 💡 NOVO PARÂMETRO: Sufixo de texto opcional
  String? suffixText,
}) {
  // Implementação omitida por brevidade, mas deve ser a mesma das telas anteriores.
  // ... (Sua implementação do _buildTextField) ...
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
            inputFormatters: inputFormatters,
            style: theme.textTheme.bodyLarge?.copyWith(color: primaryColor),
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey.shade500
                    : Colors.grey.shade600,
              ),
              // 🚨 APLICAÇÃO DO SUFIXO AQUI:
              suffixText: suffixText,
              // Estilo opcional para o sufixo (para deixá-lo discreto, se necessário)
              suffixStyle: theme.textTheme.bodyLarge?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? Colors.grey
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

// --- NOVO WIDGET AUXILIAR: Tile de Opção com Switch (Apple Like) ---
Widget _buildOptionTile({
  required ThemeData theme,
  required String title,
  required bool value,
  required ValueChanged<bool> onChanged,
  String? subtitle,
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
                  fontWeight: FontWeight.w500,
                  color: primaryColor,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  ),
                ),
              ]
            ],
          ),
        ),
        CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: primaryColor,
          trackColor: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
        ),
      ],
    ),
  );
}
// --- FIM DOS WIDGETS AUXILIARES ---

class PropertyRegistrationPage extends StatefulWidget {
  const PropertyRegistrationPage({super.key});

  @override
  State<PropertyRegistrationPage> createState() =>
      _PropertyRegistrationPageState();
}

class _PropertyRegistrationPageState extends State<PropertyRegistrationPage> {
  // Controladores de Texto
  final TextEditingController _matriculaController = TextEditingController();
  final MoneyMaskedTextController _valorVenalController =
      MoneyMaskedTextController(
    decimalSeparator: ',', // Vírgula para decimal
    thousandSeparator: '.', // Ponto para milhar
    leftSymbol: 'R\$ ', // Símbolo do Real
    precision: 2, // Duas casas decimais
  );
  // final TextEditingController _numReformasController = TextEditingController();
  // final TextEditingController _numQuartosController = TextEditingController();
  final TextEditingController _metragemController = TextEditingController();

  int _numQuartos = 1;
  int _numReformas = 0;

  // Endereço
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _logradouroController = TextEditingController();
  final TextEditingController _numeroController = TextEditingController();
  final TextEditingController _complementoController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();

  // Seletores (Cupertino-style)
  String? _tipoImovel; // Casa, Apartamento, Sala Comercial, etc.
  String? _finalidade; // Residencial ou Comercial

  // Opções Binárias
  bool _possuiGaragem = false;
  bool _isMobiliado = false;

  // Comodidades (Múltipla Seleção)
  bool _hasPiscina = false;
  bool _hasSalaoFestas = false;
  bool _hasAcademia = false;

  List<File> _propertyImages = [];
  final ImagePicker _picker = ImagePicker();

  // Formatadores
  final cepMaskFormatter = MaskTextInputFormatter(
      mask: '#####-###',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  final List<TextInputFormatter> metragemFormatter = [
    FilteringTextInputFormatter.allow(RegExp(r'[0-9,]')),
  ];

  // Tipos de Imóveis disponíveis (para o seletor)
  final List<String> _tiposDisponiveis = [
    'Apartamento',
    'Casa',
    'Sala Comercial',
    'Terreno',
    'Loft'
  ];
  final List<String> _finalidadesDisponiveis = ['Residencial', 'Comercial'];

  Future<void> _pickImages() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      setState(() {
        _propertyImages.add(imageFile);
      });
      // Opcional: Notificação de sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nova imagem adicionada!')),
        );
      }
    }
  }

  void _openMapPicker() async {
    // Coordenada inicial (Ex: Centro de SP)
    LatLng initialLocation = const LatLng(-23.5505, -46.6333);

    final SelectedLocation? result = await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => MapLocationPicker(initialCenter: initialLocation),
      ),
    );

    if (result != null) {
      // PREENCHE TODOS OS CAMPOS DE ENDEREÇO
      setState(() {
        _cepController.text = result.cep;
        _logradouroController.text = result.logradouro;

        // ADICIONAR ESTAS DUAS LINHAS:
        _cidadeController.text = result.cidade;
        _bairroController.text = result.bairro;

        // O 'Número' e 'Complemento' são mantidos para preenchimento manual.
      });

      // Opcional: Feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Localização definida: ${result.logradouro}, ${result.cidade}')),
        );
      }
    }
  }

  void _handlePropertyRegistration() {
    // TODO: Implementar a lógica de envio de dados do imóvel
    // Validação, chamada de API, etc.

    // Simulação de sucesso
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Imóvel Cadastrado"),
        content: const Text(
            "O novo imóvel foi registrado na corretora com sucesso!"),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context), // Fecha o alerta
          ),
        ],
      ),
    );
  }

  // Seletor Cupertino para Tipo/Finalidade
  void _showCupertinoPicker({
    required List<String> options,
    required String title,
    required Function(String) onSelectedItemChanged,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        // Valor inicial para o picker
        String initialValue = options.first;

        return Container(
          height: 300,
          color: CupertinoColors.white,
          child: Column(
            children: [
              // Header do Picker (com botão Done)
              Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                height: 40,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Pronto',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              // Picker
              Expanded(
                child: CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32.0,
                  onSelectedItemChanged: (int index) {
                    initialValue = options[index];
                    onSelectedItemChanged(initialValue);
                  },
                  children: List<Widget>.generate(options.length, (int index) {
                    return Center(child: Text(options[index]));
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepperField({
    required ThemeData theme,
    required String title,
    required int value,
    required ValueChanged<int> onChanged,
    int minimum = 0,
    IconData icon = CupertinoIcons.add_circled_solid,
  }) {
    final primaryColor = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;
    final boxColor = isDark ? Colors.white10 : Colors.grey.shade100;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade300, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2, // Dá um pouco mais de peso ao título
            child: Row(
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 8), // Reduzido o espaço
                Flexible(
                  // Garante que o texto encolha
                  child: Text(
                    title,
                    style:
                        theme.textTheme.bodyLarge?.copyWith(color: textColor),
                    overflow: TextOverflow
                        .ellipsis, // Opcional: Trunca se for muito longo
                  ),
                ),
              ],
            ),
          ),

          // Stepper Control
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Botão de Decremento (-)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: value > minimum ? () => onChanged(value - 1) : null,
                child: Icon(
                  CupertinoIcons.minus_circle_fill,
                  size: 30,
                  color: value > minimum ? primaryColor : Colors.grey.shade400,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  '$value',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
              // Botão de Incremento (+)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => onChanged(value + 1),
                child: Icon(CupertinoIcons.plus_circle_fill,
                    size: 30, color: primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              "Novo Imóvel",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            backgroundColor: backgroundColor,
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade300,
                width: 0.0,
              ),
            ),
            // Não precisa de leading se for a tela raiz após o login.
            // Se for um modal, você pode adicionar um 'X' aqui.
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(theme, "Mídia (Fotos)"),
                  const SizedBox(height: 16),

                  _buildImageSelector(theme, primaryColor, fieldColor),

                  const SizedBox(height: 30),

                  // --- SEÇÃO 1: IDENTIFICAÇÃO E VALORES ---
                  _buildSectionHeader(theme, "Identificação e Valores"),
                  const SizedBox(height: 16),

                  _buildTextField(
                    controller: _matriculaController,
                    hintText: "Número de Matrícula",
                    icon: CupertinoIcons.doc_text_fill,
                    inputFormatters: [
                      UpperCaseTextFormatter(),
                    ],
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _valorVenalController,
                    hintText: "Valor Venal (R\$)",
                    icon: CupertinoIcons.money_dollar_circle_fill,
                    keyboardType: TextInputType.text,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),

                  const SizedBox(height: 30),

                  // --- SEÇÃO 2: CARACTERÍSTICAS BÁSICAS ---
                  _buildSectionHeader(theme, "Características Principais"),
                  const SizedBox(height: 16),

                  // Seletor de Tipo
                  _buildPickerSelector(
                    theme: theme,
                    title: "Tipo",
                    value: _tipoImovel ?? "Selecione o Tipo...",
                    icon: CupertinoIcons.house_alt_fill,
                    onTap: () {
                      _showCupertinoPicker(
                        options: _tiposDisponiveis,
                        title: "Tipo de Imóvel",
                        onSelectedItemChanged: (value) =>
                            setState(() => _tipoImovel = value),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Seletor de Finalidade
                  _buildPickerSelector(
                    theme: theme,
                    title: "Finalidade",
                    value: _finalidade ?? "Selecione a Finalidade...",
                    icon: CupertinoIcons.flag_fill,
                    onTap: () {
                      _showCupertinoPicker(
                        options: _finalidadesDisponiveis,
                        title: "Finalidade (Residencial/Comercial)",
                        onSelectedItemChanged: (value) =>
                            setState(() => _finalidade = value),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Números (Quartos, Metragem, Reformas)
                  Row(
                    children: [
                      // QUARTOS (USANDO STEPPER)
                      Expanded(
                        child: _buildStepperField(
                          theme: theme,
                          title: "Quartos",
                          value: _numQuartos,
                          onChanged: (newVal) =>
                              setState(() => _numQuartos = newVal),
                          minimum: 1, // Mínimo de 1 quarto
                          icon: CupertinoIcons.bed_double,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _metragemController,
                          hintText: "Metragem",
                          icon: CupertinoIcons.resize,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9,]')),
                          ],
                          suffixText: ' m²',
                          theme: theme,
                          fieldColor: fieldColor,
                          primaryColor: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // REFORMAS (USANDO STEPPER)
                  _buildStepperField(
                    theme: theme,
                    title: "Nº de Reformas",
                    value: _numReformas,
                    onChanged: (newVal) =>
                        setState(() => _numReformas = newVal),
                    minimum: 0,
                    icon: CupertinoIcons.hammer_fill,
                  ),

                  const SizedBox(height: 30),

                  // --- SEÇÃO 3: INFRAESTRUTURA E COMODIDADES ---
                  _buildSectionHeader(theme, "Comodidades e Infraestrutura"),
                  const SizedBox(height: 16),

                  // Switches Binários (Garagem, Mobiliado)
                  _buildOptionTile(
                    theme: theme,
                    title: "Possui Garagem",
                    value: _possuiGaragem,
                    onChanged: (val) => setState(() => _possuiGaragem = val),
                  ),
                  const SizedBox(height: 12),
                  _buildOptionTile(
                    theme: theme,
                    title: "Imóvel Mobiliado",
                    value: _isMobiliado,
                    onChanged: (val) => setState(() => _isMobiliado = val),
                  ),
                  const SizedBox(height: 16),

                  // Comodidades
                  Text(
                    "Extras:",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  _buildOptionTile(
                    theme: theme,
                    title: "Piscina",
                    value: _hasPiscina,
                    onChanged: (val) => setState(() => _hasPiscina = val),
                  ),
                  const SizedBox(height: 12),
                  _buildOptionTile(
                    theme: theme,
                    title: "Salão de Festas",
                    value: _hasSalaoFestas,
                    onChanged: (val) => setState(() => _hasSalaoFestas = val),
                  ),
                  const SizedBox(height: 12),
                  _buildOptionTile(
                    theme: theme,
                    title: "Academia",
                    value: _hasAcademia,
                    onChanged: (val) => setState(() => _hasAcademia = val),
                  ),

                  const SizedBox(height: 30),

                  // --- SEÇÃO 4: ENDEREÇO (Seleção por Mapa/Manual) ---
                  _buildSectionHeader(
                      theme, "Endereço (Mapa ou Manual)"), // Título atualizado
                  const SizedBox(height: 16),

                  // 1. Botão/Selector que abre o mapa
                  _buildPickerSelector(
                    theme: theme,
                    title: "Localização no Mapa",
                    // Mostra o endereço completo preenchido
                    value: _logradouroController.text.isNotEmpty
                        ? "${_logradouroController.text}, ${_bairroController.text} - ${_cidadeController.text}"
                        : "Toque para selecionar no mapa...",
                    icon: CupertinoIcons.map_pin_ellipse,
                    onTap: _openMapPicker, // Chama a função que abre o mapa
                  ),
                  const SizedBox(height: 12),

                  // LINHA 1: CEP e Bairro (AGORA EDITÁVEIS)
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _cepController,
                          hintText: "CEP", // Hint simples
                          icon: CupertinoIcons.location_solid,
                          keyboardType: TextInputType.number,
                          inputFormatters: [cepMaskFormatter],
                          theme: theme, fieldColor: fieldColor,
                          primaryColor: primaryColor,
                          // REMOVIDO: enabled: false
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _bairroController,
                          hintText: "Bairro", // Hint simples
                          icon: CupertinoIcons.placemark_fill,
                          theme: theme, fieldColor: fieldColor,
                          primaryColor: primaryColor,
                          // REMOVIDO: enabled: false
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // CIDADE e LOGRADOURO (AGORA EDITÁVEIS)
                  _buildTextField(
                    controller: _cidadeController,
                    hintText: "Cidade", // Hint simples
                    icon: CupertinoIcons.building_2_fill,
                    theme: theme, fieldColor: fieldColor,
                    primaryColor: primaryColor,
                    // REMOVIDO: enabled: false
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _logradouroController,
                    hintText: "Logradouro", // Hint simples
                    icon: CupertinoIcons.square_stack_fill,
                    theme: theme, fieldColor: fieldColor,
                    primaryColor: primaryColor,
                    // REMOVIDO: enabled: false
                  ),

                  const SizedBox(height: 12),

                  // LINHA 2: Número e Complemento (Já estavam manuais)
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: _numeroController,
                          hintText: "Número",
                          icon: CupertinoIcons.number,
                          keyboardType: TextInputType.number,
                          theme: theme,
                          fieldColor: fieldColor,
                          primaryColor: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: _buildTextField(
                          controller: _complementoController,
                          hintText: "Complemento",
                          icon: CupertinoIcons.tag_fill,
                          theme: theme,
                          fieldColor: fieldColor,
                          primaryColor: primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Botão de Cadastro Final
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: CupertinoButton(
                      color: primaryColor,
                      onPressed: _handlePropertyRegistration,
                      borderRadius: BorderRadius.circular(14),
                      child: Text(
                        "Registrar Imóvel",
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

  // Widget Auxiliar para Selectores (Simula campo de texto)
  Widget _buildPickerSelector({
    required ThemeData theme,
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              child: Text(
                "$title: $value",
                style: theme.textTheme.bodyLarge?.copyWith(color: primaryColor),
              ),
            ),
            Icon(CupertinoIcons.chevron_down, color: primaryColor, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSelector(
      ThemeData theme, Color primaryColor, Color fieldColor) {
    final isDark = theme.brightness == Brightness.dark;
    const double thumbnailHeight = 80.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Botão de Adicionar Imagem
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _pickImages, // Chama a função de pick real
          child: Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              color: fieldColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: primaryColor,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(CupertinoIcons.photo_fill, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Adicionar Fotos do Imóvel",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 2. Visualização das Miniaturas (Scroll Horizontal)
        if (_propertyImages.isNotEmpty)
          SizedBox(
            height: thumbnailHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _propertyImages.length,
              itemBuilder: (context, index) {
                final File imageFile = _propertyImages[index];

                return Padding(
                  padding: EdgeInsets.only(
                      right: index == _propertyImages.length - 1 ? 0 : 12),
                  child: Stack(
                    children: [
                      // Miniatura (AGORA USA Image.file)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          imageFile, // Exibe o arquivo real
                          width: thumbnailHeight * 1.2,
                          height: thumbnailHeight,
                          fit: BoxFit.cover,
                          // Placeholder para caso o arquivo não carregue
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: isDark
                                  ? Colors.red.shade800
                                  : Colors.red.shade300,
                              child: Center(
                                child: Icon(
                                    CupertinoIcons
                                        .exclamationmark_triangle_fill,
                                    color: primaryColor),
                              ),
                            );
                          },
                        ),
                      ),

                      // Botão de Remover (Estilo X)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _propertyImages.removeAt(index);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              CupertinoIcons.xmark,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
