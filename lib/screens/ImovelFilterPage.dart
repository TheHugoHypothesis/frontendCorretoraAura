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
  final TextEditingController _localizacaoController = TextEditingController();
  final TextEditingController _minAreaController = TextEditingController();
  final TextEditingController _maxAreaController = TextEditingController();
  String _tipoFinalidade = 'Residencial';
  String? _tipoImovel;
  final List<String> _tiposImovel = const [
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
    _minAreaController.dispose();
    _maxAreaController.dispose();
    super.dispose();
  }

  // Ações
  void _aplicarFiltros() {
    final minArea = int.tryParse(_minAreaController.text);
    final maxArea = int.tryParse(_maxAreaController.text);

    print(
        'Filtros Aplicados: Finalidade: $_finalidade, Tipo: $_tipoFinalidade, Quartos: $_quartos, Área: ${minArea ?? 'Min'} - ${maxArea ?? 'Max'}');
    Navigator.pop(context);
  }

  // --- WIDGETS AUXILIARES E CUSTOMIZADOS ---

  // Cabeçalho de Seção (Style iOS nativo)
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

  // TextField Simples para Ranges (Metragem, Valor)
  Widget _buildTextFieldInline({
    String? placeholder,
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.number,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      keyboardType: keyboardType,
      textAlign: TextAlign.center,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: CupertinoColors.systemGrey4.resolveFrom(context),
            width: 0.5),
      ),
    );
  }

  // Segmented Control (CupertinoSlidingSegmentedControl)
  Widget _buildSegmentedControl<T extends Object>(
    BuildContext context, {
    required T currentValue,
    required Map<T, Widget> map,
    required void Function(T?) onValueChanged,
  }) {
    final primaryColor = CupertinoTheme.of(context).primaryColor;

    return CupertinoSlidingSegmentedControl<T>(
      groupValue: currentValue,
      onValueChanged: onValueChanged,
      padding: const EdgeInsets.all(4),
      thumbColor: primaryColor,
      backgroundColor: CupertinoColors.systemFill.resolveFrom(context),
      children: map.map((key, value) {
        final isSelected = key == currentValue;
        return MapEntry(
          key,
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              (value as Text)
                  .data!, // Remove DefaultTextStyle (causador do sublinhado)
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

  // Switch Row (CupertinoListTile com CupertinoSwitch)
  Widget _buildSwitchRow(
    BuildContext context, {
    required String label,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return CupertinoListTile(
      title: Text(label, style: const TextStyle(fontSize: 16)),
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: CupertinoTheme.of(context).primaryColor,
      ),
    );
  }

  // Number Stepper (CupertinoListTile com botões customizados)
  Widget _buildNumberStepper({
    required String label,
    required int value,
    required void Function(double) onChanged,
    required int minimum,
  }) {
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    return CupertinoListTile(
      title: Text(label, style: const TextStyle(fontSize: 16)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botão de Subtração
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
          // Botão de Adição
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

  // Tags/Chips de Comodidades
  Widget _buildAmenitiesWrap() {
    final primaryColor = CupertinoTheme.of(context).primaryColor;
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
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8), // Reduzido o padding
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
                fontSize: 14, // Tamanho da fonte menor
                color: isSelected ? CupertinoColors.white : labelColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Widget de linha para mostrar o valor selecionado (Picker Row)
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

  // Função para exibir o CupertinoPicker (Modal com a lista de opções)
  void _showPicker(
      List<String> items, void Function(int) onSelectedItemChanged) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
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

  // 1 & 5. Tipo de Transação e Finalidade
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
            onValueChanged: (value) {
              setState(() {
                _finalidade = value!;
              });
            },
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
            onValueChanged: (value) {
              setState(() {
                _tipoFinalidade = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  // 2. Valor (Preço)
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
                child: _buildTextFieldInline(
                  controller:
                      _minAreaController, // Corrigido para _minPriceController
                  placeholder: 'Mín. (ex: 100000)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Text('até',
                  style: TextStyle(
                      color: CupertinoColors.systemGrey.resolveFrom(context))),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextFieldInline(
                  controller:
                      _maxAreaController, // Corrigido para _maxPriceController
                  placeholder: 'Máx. (ex: 500000)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Localização
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

  // 4. Metragem
  Widget _buildAreaRangeSection(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: _buildListHeader('METRAGEM (ÁREA ÚTIL m²)'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            children: [
              Expanded(
                child: _buildTextFieldInline(
                  controller: _minAreaController,
                  placeholder: 'Mín. (ex: 50)',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Text('até',
                  style: TextStyle(
                      color: CupertinoColors.systemGrey.resolveFrom(context))),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextFieldInline(
                  controller: _maxAreaController,
                  placeholder: 'Máx. (ex: 150)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 6. Tipo de Imóvel
  Widget _buildTypeSection(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: _buildListHeader('TIPO DE IMÓVEL'),
      children: [
        _buildPickerRow(
          label: 'Tipo',
          selectedValue: _tipoImovel ?? 'Selecionar',
          onTap: () => _showPicker(_tiposImovel, (index) {
            setState(() {
              _tipoImovel = _tiposImovel[index];
            });
          }),
        ),
      ],
    );
  }

  // 7, 8, 9. Quartos, Garagem e Mobiliado
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

  // 10. Comodidades
  Widget _buildAmenitiesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Usamos o cabeçalho de lista, mas sem estar dentro de um ListSection para permitir o Wrap.
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
    // ⚠️ CORREÇÃO: Definir o tema Preto e Branco (B&W)
    // Usamos o MaterialApp no main.dart para definir o tema B&W
    // Aqui, vamos apenas usar as cores do tema Cupertino
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final accentColor = Colors.blue; // Cor de Ação padrão do iOS

    return CupertinoPageScaffold(
      backgroundColor: backgroundColor,
      // App Bar estilo iOS
      navigationBar: CupertinoNavigationBar(
        backgroundColor: backgroundColor,
        border: Border(
            bottom: BorderSide(
                color: isDark
                    ? CupertinoColors.systemGrey5
                    : CupertinoColors.systemGrey4,
                width: 0.5)),
        padding: const EdgeInsetsDirectional.only(end: 8),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: Text('Cancelar',
              style: TextStyle(color: accentColor)), // Cor de Ação
        ),
        middle: Text('Filtros de Imóveis',
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600)),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _aplicarFiltros,
          child: Text('Aplicar',
              style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.bold)), // Cor de Ação
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

                  // Seção de Comodidades
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
                        color: isDark
                            ? CupertinoColors.systemGrey5
                            : CupertinoColors.systemGrey4,
                        width: 0.5)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SafeArea(
                top: false,
                child: CupertinoButton(
                  color: primaryColor, // Botão Preto/Branco
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  onPressed: _aplicarFiltros,
                  child: Center(
                    child: Text(
                      'Aplicar Filtros e Buscar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: backgroundColor, // Texto Branco/Preto
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
