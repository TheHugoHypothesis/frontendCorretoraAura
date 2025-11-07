import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// **********************************************************************
//                 MOCKS DE DADOS E ESTRUTURAS (MANTIDOS)
// **********************************************************************
// (ContratoMock, PagamentoMock, AdquirenteMock e MocksList estão no escopo)

class ContratoMock {
  final String id;
  final String tipo;
  final String status;
  final String dataInicio;
  final String valor;
  final String imovel;

  const ContratoMock({
    required this.id,
    required this.tipo,
    required this.status,
    required this.dataInicio,
    required this.valor,
    required this.imovel,
  });
}

class PagamentoMock {
  final String id;
  final String tipo;
  final String status;
  final String dataVencimento;
  final String valor;
  final String imovel;

  const PagamentoMock({
    required this.id,
    required this.tipo,
    required this.status,
    required this.dataVencimento,
    required this.valor,
    required this.imovel,
  });
}

class AdquirenteMock {
  final String nome;
  final String sobrenome;
  final String cpf;
  final String telefone;
  final String email;
  final String dataNascimento;
  final String endereco;
  final String pontuacaoCredito;
  final List<ContratoMock> contratos;
  final List<PagamentoMock> pagamentos;

  const AdquirenteMock({
    required this.nome,
    required this.sobrenome,
    required this.cpf,
    required this.telefone,
    required this.email,
    required this.dataNascimento,
    required this.endereco,
    required this.pontuacaoCredito,
    required this.contratos,
    required this.pagamentos,
  });
}

// Mock Principal (Mariana)
final AdquirenteMock mockAdquirenteMariana = AdquirenteMock(
  nome: 'Mariana',
  sobrenome: 'Santos',
  cpf: '456.789.012-34',
  telefone: '(11) 99876-5432',
  email: 'mariana.santos@exemplo.com',
  dataNascimento: '15/07/1995',
  endereco: 'Rua das Flores, 100 - São Paulo',
  pontuacaoCredito: '850',
  contratos: const [
    ContratoMock(
        id: '#0025A',
        tipo: 'Aluguel',
        status: 'Vigente',
        dataInicio: '01/01/2024',
        valor: 'R\$ 3.500,00',
        imovel: 'Apto. Alameda Santos'),
  ],
  pagamentos: const [
    PagamentoMock(
        id: '#P1204',
        tipo: 'Multa',
        status: 'Atrasado',
        dataVencimento: '10/10/2025',
        valor: 'R\$ 250,00',
        imovel: 'Apto. Alameda Santos'),
    PagamentoMock(
        id: '#P1203',
        tipo: 'Aluguel',
        status: 'Pago',
        dataVencimento: '05/11/2025',
        valor: 'R\$ 3.500,00',
        imovel: 'Apto. Alameda Santos'),
  ],
);

// Lista Completa de Mocks
final List<AdquirenteMock> mockAdquirentesList = [
  mockAdquirenteMariana,
  // ... (Outros Mocks de Adquirentes)
];

// **********************************************************************
//                 WIDGETS AUXILIARES (REQUERIDOS POR DETALHES)
// **********************************************************************

Widget _buildProfileInfoTile({
  required ThemeData theme,
  required String title,
  required String value,
  required Color primaryColor,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title,
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
      Text(value,
          style: theme.textTheme.bodyLarge
              ?.copyWith(fontWeight: FontWeight.w500, color: primaryColor)),
    ]),
  );
}

Widget _buildSectionHeader(ThemeData theme, String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4.0),
    child: Text(title,
        style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
  );
}

Widget _buildTextField({
  required TextEditingController controller,
  required String hintText,
  required IconData icon,
  required ThemeData theme,
  required Color fieldColor,
  required Color primaryColor,
  bool enabled = true,
  /* Parâmetros não usados, mas necessários para evitar erros de sintaxe */
  // List<TextInputFormatter>? inputFormatters,
  // Widget? suffixIcon,
  // bool obscureText = false,
  // TextInputType keyboardType = TextInputType.text,
}) {
  final isDark = theme.brightness == Brightness.dark;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: fieldColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(
          color: isDark ? Colors.white12 : Colors.grey.shade300, width: 1),
    ),
    child: Row(children: [
      Icon(icon, color: primaryColor, size: 20),
      const SizedBox(width: 12),
      Expanded(
        child: TextField(
          controller: controller,
          enabled: enabled,
          style: theme.textTheme.bodyLarge?.copyWith(color: primaryColor),
          decoration: InputDecoration(
            hintText: hintText,
            border: InputBorder.none,
            hintStyle: TextStyle(
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade600),
          ),
        ),
      ),
    ]),
  );
}

// **********************************************************************
//                 WIDGET AUXILIAR: Tile de Análise (NOVO)
// **********************************************************************

Widget _buildAnalysisTile(
  ThemeData theme, {
  required String title,
  required String value,
  required IconData icon,
  required Color color,
}) {
  final isDark = theme.brightness == Brightness.dark;
  final primaryColor = isDark ? Colors.white : Colors.black;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: isDark ? Colors.white10 : Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// **********************************************************************
//                       CLASSE PRINCIPAL DE DETALHES
// **********************************************************************

class AdquirenteDetailPage extends StatefulWidget {
  final AdquirenteMock adquirente;

  const AdquirenteDetailPage({super.key, required this.adquirente});

  @override
  State<AdquirenteDetailPage> createState() => _AdquirenteDetailPageState();
}

class _AdquirenteDetailPageState extends State<AdquirenteDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controladores de Edição
  late TextEditingController _nomeController;
  late TextEditingController _sobrenomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _emailController;

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Aumenta o número de abas para 4 (Dados, Contratos, Pagamentos, Análise)
    _tabController = TabController(length: 4, vsync: this);

    _nomeController = TextEditingController(text: widget.adquirente.nome);
    _sobrenomeController =
        TextEditingController(text: widget.adquirente.sobrenome);
    _telefoneController =
        TextEditingController(text: widget.adquirente.telefone);
    _emailController = TextEditingController(text: widget.adquirente.email);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _telefoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _saveChanges();
      }
    });
  }

  void _saveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados do Adquirente atualizados!')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            CupertinoSliverNavigationBar(
              largeTitle: Text(
                widget.adquirente.nome,
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
              leading: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => Navigator.pop(context),
                child: Icon(CupertinoIcons.chevron_left, color: primaryColor),
              ),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _toggleEditing,
                child: Text(
                  _isEditing ? 'Salvar' : 'Editar',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color:
                        _isEditing ? CupertinoColors.activeBlue : primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Abas de Navegação
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: primaryColor,
                  labelColor: primaryColor,
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorWeight: 2,
                  labelStyle: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: 'Dados'),
                    Tab(text: 'Contratos'),
                    Tab(text: 'Pagamentos'),
                    Tab(text: 'Análise'), // ABA DE ANÁLISE INCLUÍDA
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDadosPessoaisTab(theme, primaryColor, fieldColor),
            _buildContratosTab(theme, primaryColor),
            _buildPagamentosTab(theme, primaryColor),
            _buildAnalisePerfilTab(
                theme, primaryColor), // ABA DE ANÁLISE INCLUÍDA
          ],
        ),
      ),
    );
  }

  // --- CONSTRUÇÃO DAS ABAS ---

  Widget _buildDadosPessoaisTab(
      ThemeData theme, Color primaryColor, Color fieldColor) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        _buildSectionHeader(theme, "Informações de Cliente"),
        const SizedBox(height: 16),
        _buildProfileInfoTile(
          theme: theme,
          title: "Endereço",
          value: widget.adquirente.endereco,
          primaryColor: primaryColor,
        ),
        const Divider(color: Colors.grey, height: 1),
        _buildProfileInfoTile(
          theme: theme,
          title: "Pontuação de Crédito",
          value: widget.adquirente.pontuacaoCredito,
          primaryColor: primaryColor,
        ),
        const Divider(color: Colors.grey, height: 1),
        _buildProfileInfoTile(
          theme: theme,
          title: "CPF",
          value: widget.adquirente.cpf,
          primaryColor: primaryColor,
        ),
        const Divider(color: Colors.grey, height: 1),
        _buildProfileInfoTile(
          theme: theme,
          title: "Data de Nasc.",
          value: widget.adquirente.dataNascimento,
          primaryColor: primaryColor,
        ),
        const Divider(color: Colors.grey, height: 1),
        const SizedBox(height: 30),
        _buildSectionHeader(theme, "Detalhes de Contato"),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nomeController,
          hintText: "Nome",
          icon: CupertinoIcons.person_crop_circle_fill,
          theme: theme,
          fieldColor: fieldColor,
          primaryColor: primaryColor,
          enabled: _isEditing,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _sobrenomeController,
          hintText: "Sobrenome",
          icon: CupertinoIcons.person_crop_circle,
          theme: theme,
          fieldColor: fieldColor,
          primaryColor: primaryColor,
          enabled: _isEditing,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _telefoneController,
          hintText: "Telefone",
          icon: CupertinoIcons.phone_fill,
          theme: theme,
          fieldColor: fieldColor,
          primaryColor: primaryColor,
          enabled: _isEditing,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _emailController,
          hintText: "E-mail",
          icon: CupertinoIcons.mail_solid,
          theme: theme,
          fieldColor: fieldColor,
          primaryColor: primaryColor,
          enabled: _isEditing,
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildContratosTab(ThemeData theme, Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        _buildSectionHeader(theme, "Histórico Contratual"),
        const SizedBox(height: 16),
        ...widget.adquirente.contratos.map((contrato) {
          final isVigente = contrato.status == 'Vigente';
          final isFinalizado = contrato.status == 'Finalizado';
          final statusColor = isVigente
              ? CupertinoColors.activeGreen
              : isFinalizado
                  ? Colors.grey.shade600
                  : Colors.orange.shade700;
          final borderColor =
              isVigente ? Colors.blue.shade400 : Colors.grey.shade300;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: isVigente
                      ? Colors.blue.shade50.withOpacity(0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: borderColor,
                    width: 1,
                  )),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${contrato.tipo} ${contrato.id}",
                        style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(contrato.status,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Imóvel: ${contrato.imovel}",
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey.shade600)),
                  Text("Valor: ${contrato.valor}",
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: primaryColor)),
                  Text("Início: ${contrato.dataInicio}",
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey)),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _buildPagamentosTab(ThemeData theme, Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        _buildSectionHeader(theme, "Histórico de Pagamentos"),
        const SizedBox(height: 16),
        ...widget.adquirente.pagamentos.map((pagamento) {
          final isPago = pagamento.status == 'Pago';
          final isAtrasado = pagamento.status == 'Atrasado';
          final color = isPago
              ? CupertinoColors.activeGreen
              : (isAtrasado ? Colors.red.shade700 : Colors.orange.shade700);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                isPago
                    ? CupertinoIcons.checkmark_circle_fill
                    : CupertinoIcons.xmark_circle_fill,
                color: color,
                size: 30,
              ),
              title: Text(
                pagamento.valor,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold, color: color),
              ),
              subtitle: Text(
                "${pagamento.tipo} - ${pagamento.imovel}",
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey.shade600),
              ),
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(pagamento.status,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: color, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Venc.: ${pagamento.dataVencimento}",
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey)),
                ],
              ),
              onTap: () {
                // TODO: Navegar para detalhes do pagamento
              },
            ),
          );
        }).toList(),
        const SizedBox(height: 50),
      ],
    );
  }

  // **********************************************************************
  //                    CONSTRUÇÃO DA ABA DE ANÁLISE (RF04)
  // **********************************************************************

  Widget _buildAnalisePerfilTab(ThemeData theme, Color primaryColor) {
    // Lógica para calcular as métricas de perfil
    final List<ContratoMock> contratos = widget.adquirente.contratos;
    final List<PagamentoMock> pagamentos = widget.adquirente.pagamentos;

    // 1. Padrão de Permanência
    final totalContracts = contratos.length;

    // 2. Análise de Risco
    final latePayments = pagamentos
        .where((p) => p.status == 'Atrasado' || p.status == 'Multa')
        .length;
    final riskLevel = latePayments > 0 ? 'ALTO' : 'BAIXO';
    final riskColor =
        latePayments > 0 ? Colors.red.shade700 : CupertinoColors.activeGreen;

    // 3. Preferência de Imóvel (Dominante)
    final Map<String, int> typeCounts = {};
    for (var c in contratos) {
      // Simplifica o tipo de imóvel (Ex: "Apto. Alameda Santos" -> "Apto.")
      typeCounts[c.imovel.split(' ').first] =
          (typeCounts[c.imovel.split(' ').first] ?? 0) + 1;
    }
    final dominantType = typeCounts.keys.isNotEmpty
        ? typeCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'Não definido';

    final int pontuacao = int.tryParse(widget.adquirente.pontuacaoCredito) ?? 0;

    // 2. Aplica a lógica com a precedência correta (Pontuação > 800 E Contratos > 0)
    final growthTrend = (pontuacao > 800 && totalContracts > 0)
        ? 'Ascendente (Upsell)'
        : 'Estável';

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        _buildSectionHeader(theme, "Resumo de Risco e Preferência"),
        const SizedBox(height: 16),

        // Risco
        _buildAnalysisTile(
          theme,
          title: "Nível de Risco Contratual",
          value: riskLevel,
          icon: CupertinoIcons.exclamationmark_triangle_fill,
          color: riskColor,
        ),
        const SizedBox(height: 12),

        // Contratos e permanência
        _buildAnalysisTile(
          theme,
          title: "Contratos no Histórico",
          value: '$totalContracts',
          icon: CupertinoIcons.doc_chart_fill,
          color: primaryColor,
        ),
        const SizedBox(height: 12),

        // Pagamentos Atrasados
        _buildAnalysisTile(
          theme,
          title: "Eventos de Multa/Atraso",
          value: '$latePayments',
          icon: CupertinoIcons.clock_fill,
          color: latePayments > 0 ? Colors.red.shade700 : Colors.grey,
        ),

        const SizedBox(height: 30),

        _buildSectionHeader(theme, "Perfil de Consumo (BI)"),
        const SizedBox(height: 16),

        // Preferência Dominante
        _buildAnalysisTile(
          theme,
          title: "Tipo de Imóvel Preferido",
          value: dominantType,
          icon: CupertinoIcons.house_alt_fill,
          color: CupertinoColors.activeBlue,
        ),
        const SizedBox(height: 12),

        // Tendência de Crescimento
        _buildAnalysisTile(
          theme,
          title: "Tendência de Valor",
          value: growthTrend,
          icon: CupertinoIcons.chart_bar_alt_fill,
          color: growthTrend.contains('Ascendente')
              ? CupertinoColors.activeGreen
              : Colors.grey,
        ),
        const SizedBox(height: 12),

        // Endereço de Atuação
        _buildAnalysisTile(
          theme,
          title: "Último Endereço de Contrato",
          value: widget.adquirente.endereco.split(',').last.trim(),
          icon: CupertinoIcons.map_pin_ellipse,
          color: primaryColor,
        ),

        const SizedBox(height: 50),
      ],
    );
  }
}
