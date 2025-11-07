import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:intl/intl.dart';

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

// Widget Auxiliar para Selectores de Picker (Simula campo de texto)
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

// --- WIDGET AUXILIAR CORRIGIDO: Seletor de Data Estilo Cupertino ---
Widget _buildDatePickerSelector({
  // CORREÇÃO: Adicione BuildContext como parâmetro obrigatório
  required BuildContext context,
  required ThemeData theme,
  required String title,
  required DateTime? selectedDate,
  required IconData icon,
  required Function(DateTime) onDateSelected,
}) {
  final isDark = theme.brightness == Brightness.dark;
  final primaryColor = isDark ? Colors.white : Colors.black;
  final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

  String dateText = selectedDate == null
      ? "Selecione a Data..."
      : DateFormat('dd/MM/yyyy').format(selectedDate);

  return GestureDetector(
    onTap: () {
      showCupertinoModalPopup(
        context: context, // Usando o contexto recebido
        builder: (BuildContext context) {
          DateTime tempDate = selectedDate ?? DateTime.now();

          return Container(
            height: 300,
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  height: 40,
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      onDateSelected(tempDate);
                      Navigator.pop(context);
                    },
                    child: const Text('Pronto',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: tempDate,
                    onDateTimeChanged: (DateTime newDateTime) {
                      tempDate = newDateTime;
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
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
              "$title: $dateText",
              style: theme.textTheme.bodyLarge?.copyWith(color: primaryColor),
            ),
          ),
          Icon(CupertinoIcons.calendar, color: primaryColor, size: 16),
        ],
      ),
    ),
  );
}

// ====================================================================
// PÁGINA: ContractRegistrationPage (Final)
// ====================================================================

class ContractRegistrationPage extends StatefulWidget {
  const ContractRegistrationPage({super.key});

  @override
  State<ContractRegistrationPage> createState() =>
      _ContractRegistrationPageState();
}

class _ContractRegistrationPageState extends State<ContractRegistrationPage> {
  // Controladores e variáveis de estado...
  final TextEditingController _valorController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _cpfAdquirenteController =
      TextEditingController();
  final TextEditingController _cpfProprietarioController =
      TextEditingController();
  final TextEditingController _matriculaImovelController =
      TextEditingController();
  String? _tipoContrato = 'Venda';
  final List<String> _tiposContratoDisponiveis = ['Venda', 'Aluguel'];
  DateTime? _dataInicioAluguel;
  DateTime? _dataFimAluguel;
  final cpfMaskFormatter = MaskTextInputFormatter(
      mask: '###.###.###-##',
      filter: {"#": RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy);

  void _handleContractRegistration() {
    // Lógica de envio de dados...
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("Contrato Cadastrado"),
        content: Text(
            "O novo Contrato de $_tipoContrato foi registrado com sucesso!"),
        actions: [
          CupertinoDialogAction(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showContractTypePicker() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        String initialValue = _tipoContrato ?? _tiposContratoDisponiveis.first;
        int initialIndex = _tiposContratoDisponiveis.indexOf(initialValue);

        return Container(
          height: 300,
          color: CupertinoColors.white,
          child: Column(
            children: [
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
              Expanded(
                child: CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32.0,
                  scrollController: FixedExtentScrollController(
                    initialItem: initialIndex < 0 ? 0 : initialIndex,
                  ),
                  onSelectedItemChanged: (int index) {
                    setState(() {
                      _tipoContrato = _tiposContratoDisponiveis[index];
                      if (_tipoContrato == 'Venda') {
                        _dataInicioAluguel = null;
                        _dataFimAluguel = null;
                      }
                    });
                  },
                  children: List<Widget>.generate(
                      _tiposContratoDisponiveis.length, (int index) {
                    return Center(
                        child: Text(_tiposContratoDisponiveis[index]));
                  }),
                ),
              ),
            ],
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
    final primaryColor = theme.primaryColor;
    final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              "Novo Contrato",
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... (Seções 1, 2, 3 - Campos Comuns)

                  _buildSectionHeader(theme, "Tipo de Contrato"),
                  const SizedBox(height: 16),
                  _buildPickerSelector(
                    theme: theme,
                    title: "Tipo",
                    value: _tipoContrato ?? "Selecione o Tipo...",
                    icon: CupertinoIcons.doc_fill,
                    onTap: _showContractTypePicker,
                  ),
                  const SizedBox(height: 30),

                  _buildSectionHeader(theme, "Detalhes Financeiros e Status"),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _valorController,
                    hintText: "Valor Total (R\$)",
                    icon: CupertinoIcons.money_dollar_circle_fill,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _statusController,
                    hintText: "Status (Ex: Ativo, Finalizado, Pendente)",
                    icon: CupertinoIcons.hourglass,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 30),

                  _buildSectionHeader(
                      theme, "Identificação das Partes e Imóvel"),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _matriculaImovelController,
                    hintText: "Matrícula do Imóvel",
                    icon: CupertinoIcons.building_2_fill,
                    keyboardType: TextInputType.number,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _cpfAdquirenteController,
                    hintText: "CPF do Adquirente",
                    icon: CupertinoIcons.person_alt_circle_fill,
                    keyboardType: TextInputType.number,
                    inputFormatters: [cpfMaskFormatter],
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _cpfProprietarioController,
                    hintText: "CPF do Proprietário",
                    icon: CupertinoIcons.person_alt_circle_fill,
                    keyboardType: TextInputType.number,
                    inputFormatters: [cpfMaskFormatter],
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),

                  // --- SEÇÃO 4: DATAS DE ALUGUEL (Condicional) ---
                  if (_tipoContrato == 'Aluguel') ...[
                    const SizedBox(height: 30),
                    _buildSectionHeader(theme, "Datas do Aluguel"),
                    const SizedBox(height: 16),
                    _buildDatePickerSelector(
                      context: context, // CHAMADA CORRIGIDA
                      theme: theme,
                      title: "Início do Contrato",
                      selectedDate: _dataInicioAluguel,
                      icon: CupertinoIcons.play_fill,
                      onDateSelected: (date) {
                        setState(() => _dataInicioAluguel = date);
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDatePickerSelector(
                      context: context, // CHAMADA CORRIGIDA
                      theme: theme,
                      title: "Fim do Contrato",
                      selectedDate: _dataFimAluguel,
                      icon: CupertinoIcons.stop_fill,
                      onDateSelected: (date) {
                        setState(() => _dataFimAluguel = date);
                      },
                    ),
                  ],

                  const SizedBox(height: 40),

                  // Botão de Cadastro Final
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: CupertinoButton(
                      color: primaryColor,
                      onPressed: _handleContractRegistration,
                      borderRadius: BorderRadius.circular(14),
                      child: Text(
                        "Registrar Contrato de $_tipoContrato",
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
}
