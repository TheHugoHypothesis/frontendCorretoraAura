import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Este Widget mantém o estado de todos os filtros selecionados pelo usuário.
class ImovelFilterPage extends StatefulWidget {
  const ImovelFilterPage({super.key});

  @override
  State<ImovelFilterPage> createState() => _ImovelFilterPageState();
}

class _ImovelFilterPageState extends State<ImovelFilterPage> {
  // --- Variáveis de Estado (Filtros) ---
  String _finalidade = 'Venda';
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _localizacaoController = TextEditingController();
  final TextEditingController _minAreaController = TextEditingController();
  final TextEditingController _maxAreaController = TextEditingController();
  String _tipoFinalidade = 'Residencial';
  String? _propertyType;
  final List<String> _propertyTypes = const [
    'Apartamento',
    'Casa',
    'Cobertura',
    'Kitnet/Conjugado',
    'Lote/Terreno',
    'Outros'
  ];
  int _quartos = 1;
  bool _temGaragem = false;
  bool _eMobiliado = false;

  final Map<String, bool> _comodidades = {
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
  // ------------------------------------

  @override
  void dispose() {
    _localizacaoController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minAreaController.dispose();
    _maxAreaController.dispose();
    super.dispose();
  }

  void _aplicarFiltros() {
    final minPrice = _minPriceController.text;
    final maxPrice = _maxPriceController.text;
    final minArea = _minAreaController.text;
    final maxArea = _maxAreaController.text;

    // Coletar todos os dados e retornar para a Home
    final filters = {
      'transaction': _finalidade,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minArea': minArea,
      'maxArea': maxArea,
      'purpose': _tipoFinalidade,
      'type': _propertyType,
      'bedrooms': _quartos,
      'hasGarage': _temGaragem,
      'isFurnished': _eMobiliado,
      'amenities': _comodidades.keys.where((k) => _comodidades[k]!).toList(),
    };
    Navigator.pop(context, filters);
  }

  // --- WIDGETS AUXILIARES E CUSTOMIZADOS (AGORA DENTRO DO ESCOPO) ---

  Widget _buildListHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: CupertinoColors.systemGrey.resolveFrom(context),
        ),
      ),
    );
  }

  Widget _buildCustomInputField({
    String? placeholder,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.number,
    String? prefixText,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyLarge?.copyWith(color: primaryColor),
        decoration: InputDecoration(
          hintText: placeholder,
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixText: prefixText,
        ),
      ),
    );
  }

  Widget _buildSegmentedControl<T extends Object>(
    BuildContext context, {
    required T currentValue,
    required Map<T, Widget> map,
    required void Function(T?) onValueChanged,
  }) {
    final accentColor = CupertinoColors.systemBlue;

    return CupertinoSlidingSegmentedControl<T>(
      groupValue: currentValue,
      onValueChanged: onValueChanged,
      padding: const EdgeInsets.all(4),
      thumbColor: accentColor,
      backgroundColor: CupertinoColors.systemFill.resolveFrom(context),
      children: map.map((key, value) {
        final isSelected = key == currentValue;
        return MapEntry(
          key,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              (value as Text).data!,
              style: TextStyle(
                color: isSelected
                    ? CupertinoColors.white
                    : CupertinoColors.label.resolveFrom(context),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 15,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSwitchRow(
    BuildContext context, {
    required String label,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    return CupertinoListTile(
      title: Text(label, style: const TextStyle(fontSize: 16)),
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: primaryColor,
      ),
    );
  }

  Widget _buildNumberStepper({
    required String label,
    required int value,
    required void Function(double) onChanged,
    required int minimum,
  }) {
    final theme = Theme.of(context);
    final primaryColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return CupertinoListTile(
      title: Text(label, style: const TextStyle(fontSize: 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: value > minimum
                ? () => onChanged((value - 1).toDouble())
                : null,
            child: Icon(CupertinoIcons.minus_circle_fill,
                size: 30,
                color: value > minimum
                    ? primaryColor
                    : CupertinoColors.systemGrey),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Text('$value',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => onChanged((value + 1).toDouble()),
            child: Icon(CupertinoIcons.plus_circle_fill,
                size: 30, color: primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenitiesWrap() {
    final theme = Theme.of(context);
    final primaryColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    final labelColor = CupertinoColors.label.resolveFrom(context);

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _comodidades.keys.map((amenity) {
        final isSelected = _comodidades[amenity]!;
        return GestureDetector(
          onTap: () {
            setState(() {
              _comodidades[amenity] = !isSelected;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor
                  : CupertinoColors.systemBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? primaryColor
                    : CupertinoColors.systemGrey4.resolveFrom(context),
                width: 1,
              ),
            ),
            child: Text(
              amenity,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? CupertinoColors.white : labelColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPickerRow(
      {required String label,
      required String selectedValue,
      required VoidCallback onTap}) {
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    return CupertinoListTile(
      title: Text(label, style: const TextStyle(fontSize: 16)),
      trailing: GestureDetector(
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedValue,
              style: TextStyle(
                  color: selectedValue == 'Selecionar'
                      ? CupertinoColors.systemGrey.resolveFrom(context)
                      : primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 4),
            Icon(CupertinoIcons.chevron_right,
                size: 16, color: CupertinoColors.systemGrey),
          ],
        ),
      ),
    );
  }

  void _showPicker(
      List<String> items, void Function(int) onSelectedItemChanged) {
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
            onSelectedItemChanged: onSelectedItemChanged,
            children: List<Widget>.generate(items.length, (int index) {
              return Center(child: Text(items[index]));
            }),
          ),
        ),
      ),
    );
  }

  // --- CONSTRUÇÃO DAS SEÇÕES ---

  Widget _buildTransactionAndPurposeSection(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: _buildListHeader('TIPO DE NEGÓCIO E FINALIDADE'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: _buildSegmentedControl<String>(
            context,
            currentValue: _finalidade,
            map: const <String, Widget>{
              'Venda': Text('Venda'),
              'Locação': Text('Locação'),
            },
            onValueChanged: (value) => setState(() => _finalidade = value!),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: _buildSegmentedControl<String>(
            context,
            currentValue: _tipoFinalidade,
            map: const <String, Widget>{
              'Residencial': Text('Residencial'),
              'Comercial': Text('Comercial'),
            },
            onValueChanged: (value) => setState(() => _tipoFinalidade = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSection(BuildContext context) {
    final unit = _finalidade == 'Venda' ? 'R\$ (Venda)' : 'R\$ (Aluguel/Mês)';
    return CupertinoListSection.insetGrouped(
      header: _buildListHeader('VALOR DO IMÓVEL ($unit)'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            children: [
              Expanded(
                child: _buildCustomInputField(
                  controller: _minPriceController,
                  placeholder: 'Mín. (R\$)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Text('até',
                  style: TextStyle(
                      color: CupertinoColors.systemGrey.resolveFrom(context))),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCustomInputField(
                  controller: _maxPriceController,
                  placeholder: 'Máx. (R\$)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: _buildListHeader('LOCALIZAÇÃO'),
      children: [
        CupertinoListTile(
          padding: EdgeInsets.zero,
          title: CupertinoTextField(
            controller: _localizacaoController,
            placeholder: 'Estado, Cidade, Bairro ou Rua...',
            keyboardType: TextInputType.text,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: const BoxDecoration(
              color: CupertinoColors.tertiarySystemFill,
            ),
            prefix: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Icon(CupertinoIcons.search,
                  color: CupertinoColors.systemGrey),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAreaRangeSection(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: _buildListHeader('METRAGEM (ÁREA ÚTIL m²)'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            children: [
              Expanded(
                child: _buildCustomInputField(
                  controller: _minAreaController,
                  placeholder: 'Mín. (m²)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Text('até',
                  style: TextStyle(
                      color: CupertinoColors.systemGrey.resolveFrom(context))),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCustomInputField(
                  controller: _maxAreaController,
                  placeholder: 'Máx. (m²)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSection(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: _buildListHeader('TIPO DE IMÓVEL'),
      children: [
        _buildPickerRow(
          label: 'Tipo',
          selectedValue: _propertyType ?? 'Selecionar',
          onTap: () => _showPicker(_propertyTypes, (index) {
            setState(() {
              _propertyType = _propertyTypes[index];
            });
          }),
        ),
      ],
    );
  }

  Widget _buildFeaturesAndBedroomsSection(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: _buildListHeader('CARACTERÍSTICAS'),
      children: [
        _buildNumberStepper(
          label: 'Número de Quartos',
          value: _quartos,
          onChanged: (newVal) => setState(() => _quartos = newVal.toInt()),
          minimum: 1,
        ),
        _buildSwitchRow(
          context,
          label: 'Acesso à Garagem',
          value: _temGaragem,
          onChanged: (val) => setState(() => _temGaragem = val),
        ),
        _buildSwitchRow(
          context,
          label: 'Imóvel Mobiliado',
          value: _eMobiliado,
          onChanged: (val) => setState(() => _eMobiliado = val),
        ),
      ],
    );
  }

  Widget _buildAmenitiesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildListHeader('COMODIDADES'),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: _buildAmenitiesWrap(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    final isDarkMode = CupertinoTheme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final accentColor = CupertinoColors.systemBlue;

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      // App Bar estilo iOS
      navigationBar: CupertinoNavigationBar(
        backgroundColor: backgroundColor,
        border: Border(
            bottom: BorderSide(
                color: isDarkMode
                    ? CupertinoColors.systemGrey5
                    : CupertinoColors.systemGrey4,
                width: 0.5)),
        padding: const EdgeInsetsDirectional.only(end: 8),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar', style: TextStyle(color: accentColor)),
        ),
        middle: Text('Filtros de Imóveis',
            style: TextStyle(
                color:
                    isDarkMode ? CupertinoColors.white : CupertinoColors.black,
                fontWeight: FontWeight.w600)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _aplicarFiltros,
          child: Text('Aplicar',
              style:
                  TextStyle(color: accentColor, fontWeight: FontWeight.bold)),
        ),
      ),

      // Corpo principal
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildTransactionAndPurposeSection(context),
                  _buildPriceRangeSection(context),
                  _buildLocationSection(context),
                  _buildAreaRangeSection(context),
                  _buildTypeSection(context),
                  _buildFeaturesAndBedroomsSection(context),
                  _buildAmenitiesSection(context),
                  const SizedBox(height: 80),
                ],
              ),
            ),

            // BOTÃO FLUTUANTE DE APLICAR FILTROS
            Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(
                    top: BorderSide(
                        color: isDarkMode
                            ? CupertinoColors.systemGrey5
                            : CupertinoColors.systemGrey4,
                        width: 0.5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SafeArea(
                top: false,
                child: CupertinoButton.filled(
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onPressed: _aplicarFiltros,
                  child: Center(
                    child: Text(
                      'Aplicar Filtros e Buscar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
