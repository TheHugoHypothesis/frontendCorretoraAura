import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Página: filter_imovel.dart
// Descrição: Página Apple-like para seleção de filtros de imóveis.
// Retorna um Map<String, dynamic> com os filtros selecionados via Navigator.pop(context, filtersMap)

class FilterImovelPage extends StatefulWidget {
  const FilterImovelPage({super.key});

  @override
  State<FilterImovelPage> createState() => _FilterImovelPageState();
}

class _FilterImovelPageState extends State<FilterImovelPage> {
  // CONTROLLERS DE ENDEREÇO
  final TextEditingController _estadoController = TextEditingController();
  final TextEditingController _cidadeController = TextEditingController();
  final TextEditingController _bairroController = TextEditingController();
  final TextEditingController _ruaController = TextEditingController();

  // METRAGEM
  final TextEditingController _metragemMinController = TextEditingController();
  final TextEditingController _metragemMaxController = TextEditingController();

  // VALOR (RANGE)
  RangeValues _valorRange = const RangeValues(100000, 1000000);
  final double _valorMinLimit = 0;
  final double _valorMaxLimit = 5000000;

  // TIPO / FINALIDADE
  String? _tipoSelecionado;
  String? _finalidadeSelecionada;
  final List<String> _tiposDisponiveis = [
    'Apartamento',
    'Casa',
    'Cobertura',
    'Kitnet/Conjugado',
    'Sala Comercial',
    'Terreno',
    'Loft'
  ];
  final List<String> _finalidadesDisponiveis = ['Residencial', 'Comercial'];

  // QUARTOS
  int _numQuartos = 1;

  // SWITCHES
  bool _possuiGaragem = false;
  bool _isMobiliado = false;

  // COMODIDADES
  Map<String, bool> _comodidades = {
    'Piscina': false,
    'Churrasqueira': false,
    'Salão de Festas': false,
    'Academia': false,
    'Playground': false,
    'Portaria 24h': false,
    'Elevador': false,
    'Aceita Pet': false,
    'Ar Condicionado': false,
    'Varanda/Sacada': false,
  };

  // THEME-DEPENDENT COLORS (calculados no build)

  // FUNÇÃO PARA ABRIR PICKER (USADO PARA TIPO / FINALIDADE)
  void _showCupertinoPicker({
    required List<String> options,
    required String title,
    required Function(String) onSelectedItemChanged,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        String initialValue = options.first;
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

  // Retorna o Map com filtros selecionados
  void _applyFilters() {
    final filters = <String, dynamic>{
      'valorMin': _valorRange.start.toInt(),
      'valorMax': _valorRange.end.toInt(),
      'estado': _estadoController.text.trim(),
      'cidade': _cidadeController.text.trim(),
      'bairro': _bairroController.text.trim(),
      'rua': _ruaController.text.trim(),
      'metragemMin': _metragemMinController.text.trim().isEmpty
          ? null
          : int.tryParse(
              _metragemMinController.text.replaceAll(RegExp(r'[^0-9]'), '')),
      'metragemMax': _metragemMaxController.text.trim().isEmpty
          ? null
          : int.tryParse(
              _metragemMaxController.text.replaceAll(RegExp(r'[^0-9]'), '')),
      'tipo': _tipoSelecionado,
      'finalidade': _finalidadeSelecionada,
      'numQuartos': _numQuartos,
      'possuiGaragem': _possuiGaragem,
      'mobiliado': _isMobiliado,
      'comodidades': Map<String, bool>.from(_comodidades),
    };

    Navigator.of(context).pop(filters);
  }

  void _clearFilters() {
    setState(() {
      _estadoController.clear();
      _cidadeController.clear();
      _bairroController.clear();
      _ruaController.clear();
      _metragemMinController.clear();
      _metragemMaxController.clear();
      _valorRange = const RangeValues(100000, 1000000);
      _tipoSelecionado = null;
      _finalidadeSelecionada = null;
      _numQuartos = 1;
      _possuiGaragem = false;
      _isMobiliado = false;
      _comodidades.updateAll((key, value) => false);
    });
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
              'Filtrar Imóveis',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            backgroundColor: backgroundColor,
            border: Border(
              bottom: BorderSide(
                  color: isDark ? Colors.white12 : Colors.grey.shade300,
                  width: 0.0),
            ),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _clearFilters,
              child: Text('Limpar',
                  style: TextStyle(
                      color: primaryColor, fontWeight: FontWeight.w600)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(theme, 'Valor'),
                  const SizedBox(height: 12),

                  // Range Slider de Valor
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: fieldColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color:
                              isDark ? Colors.white12 : Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Faixa de preço (R\$)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: primaryColor,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        RangeSlider(
                          values: _valorRange,
                          min: _valorMinLimit,
                          max: _valorMaxLimit,
                          divisions: 100,
                          labels: RangeLabels(
                            'R\$ ${_valorRange.start.toInt()}',
                            'R\$ ${_valorRange.end.toInt()}',
                          ),
                          onChanged: (RangeValues values) {
                            setState(() => _valorRange = values);
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Min: R\$ ${_valorRange.start.toInt()}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade700)),
                            Text('Max: R\$ ${_valorRange.end.toInt()}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark
                                        ? Colors.grey.shade300
                                        : Colors.grey.shade700)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  _buildSectionHeader(theme, 'Localização'),
                  const SizedBox(height: 12),

                  // Estado / Cidade / Bairro / Rua
                  _buildTextField(
                    controller: _estadoController,
                    hintText: 'Estado',
                    icon: CupertinoIcons.location,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _cidadeController,
                    hintText: 'Cidade',
                    icon: CupertinoIcons.building_2_fill,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _bairroController,
                    hintText: 'Bairro',
                    icon: CupertinoIcons.placemark_fill,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: _ruaController,
                    hintText: 'Rua',
                    icon: CupertinoIcons.map_pin_ellipse,
                    theme: theme,
                    fieldColor: fieldColor,
                    primaryColor: primaryColor,
                  ),

                  const SizedBox(height: 24),

                  _buildSectionHeader(theme, 'Metragem (Área útil)'),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _metragemMinController,
                          hintText: 'Mínimo (m²)',
                          icon: CupertinoIcons.minus_circle,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          theme: theme,
                          fieldColor: fieldColor,
                          primaryColor: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          controller: _metragemMaxController,
                          hintText: 'Máximo (m²)',
                          icon: CupertinoIcons.add_circled,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          theme: theme,
                          fieldColor: fieldColor,
                          primaryColor: primaryColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildSectionHeader(theme, 'Tipo e Finalidade'),
                  const SizedBox(height: 12),

                  // Tipo
                  _buildPickerSelector(
                    theme: theme,
                    title: 'Tipo',
                    value: _tipoSelecionado ?? 'Qualquer tipo',
                    icon: CupertinoIcons.square_list_fill,
                    onTap: () {
                      _showCupertinoPicker(
                        options: _tiposDisponiveis,
                        title: 'Tipo de Imóvel',
                        onSelectedItemChanged: (value) =>
                            setState(() => _tipoSelecionado = value),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Finalidade
                  _buildPickerSelector(
                    theme: theme,
                    title: 'Finalidade',
                    value: _finalidadeSelecionada ?? 'Qualquer finalidade',
                    icon: CupertinoIcons.flag_fill,
                    onTap: () {
                      _showCupertinoPicker(
                        options: _finalidadesDisponiveis,
                        title: 'Finalidade',
                        onSelectedItemChanged: (value) =>
                            setState(() => _finalidadeSelecionada = value),
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  _buildSectionHeader(theme, 'Quartos'),
                  const SizedBox(height: 12),

                  _buildStepperField(
                    theme: theme,
                    title: 'Número de Quartos',
                    value: _numQuartos,
                    onChanged: (newVal) => setState(() => _numQuartos = newVal),
                    minimum: 0,
                    icon: CupertinoIcons.bed_double,
                  ),

                  const SizedBox(height: 24),

                  _buildSectionHeader(theme, 'Características'),
                  const SizedBox(height: 12),

                  _buildOptionTile(
                    theme: theme,
                    title: 'Possui Garagem',
                    value: _possuiGaragem,
                    onChanged: (val) => setState(() => _possuiGaragem = val),
                  ),
                  const SizedBox(height: 12),
                  _buildOptionTile(
                    theme: theme,
                    title: 'Mobiliado',
                    value: _isMobiliado,
                    onChanged: (val) => setState(() => _isMobiliado = val),
                  ),

                  const SizedBox(height: 20),
                  Text('Comodidades',
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600, color: primaryColor)),
                  const SizedBox(height: 12),

                  // Lista de comodidades (switches)
                  Column(
                    children: _comodidades.keys.map((key) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildOptionTile(
                          theme: theme,
                          title: key,
                          value: _comodidades[key]!,
                          onChanged: (val) =>
                              setState(() => _comodidades[key] = val),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 32),

                  // Botões de Ação
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: CupertinoButton(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(14),
                            padding: EdgeInsets.zero,
                            onPressed: () => Navigator.of(context).pop(),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: isDark
                                        ? Colors.white12
                                        : Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(14),
                                color: fieldColor,
                              ),
                              child: Text('Cancelar',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: CupertinoButton(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(14),
                            onPressed: _applyFilters,
                            child: Text('Aplicar filtros',
                                style: theme.textTheme.titleMedium?.copyWith(
                                    color: backgroundColor,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== WIDGETS AUXILIARES (BASEADOS NO SEU PADRÃO) ====================

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
              color: isDark ? Colors.white12 : Colors.grey.shade300, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: primaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text('$title: $value',
                  style:
                      theme.textTheme.bodyLarge?.copyWith(color: primaryColor)),
            ),
            Icon(CupertinoIcons.chevron_down, color: primaryColor, size: 16),
          ],
        ),
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
    String? suffixText,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: theme.brightness == Brightness.dark
                ? Colors.white12
                : Colors.grey.shade300,
            width: 1),
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
                        : Colors.grey.shade600),
                suffixText: suffixText,
                suffixStyle: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.brightness == Brightness.dark
                        ? Colors.grey
                        : Colors.grey.shade600),
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon,
        ],
      ),
    );
  }

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
            color: isDark ? Colors.white12 : Colors.grey.shade300, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500, color: primaryColor)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600)),
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
            flex: 2,
            child: Row(
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(title,
                      style:
                          theme.textTheme.bodyLarge?.copyWith(color: textColor),
                      overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: value > minimum ? () => onChanged(value - 1) : null,
                child: Icon(CupertinoIcons.minus_circle_fill,
                    size: 30,
                    color:
                        value > minimum ? primaryColor : Colors.grey.shade400),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('$value',
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold, color: textColor)),
              ),
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
}
