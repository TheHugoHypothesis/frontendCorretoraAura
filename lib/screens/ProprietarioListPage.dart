import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// **********************************************************************
//                 MOCKS DE DADOS E ESTRUTURAS
// **********************************************************************

class ContratoMock {
  final String id;
  final String tipo; // Venda ou Aluguel
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
  final String tipo; // Aluguel, Parcela, Multa
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

class ImovelMock {
  final String matricula;
  final String endereco;
  final String statusOcupacao; // Ex: "Alugado", "Vendido", "Disponível"
  final String valorVenal;
  final List<ContratoMock> contratos; // Contratos relacionados a este imóvel

  const ImovelMock({
    required this.matricula,
    required this.endereco,
    required this.statusOcupacao,
    required this.valorVenal,
    required this.contratos,
  });
}

class ProprietarioMock {
  final String nome;
  final String sobrenome;
  final String cpf;
  final String telefone;
  final String email;
  final List<ImovelMock> imoveis;
  final String dataNascimento;

  const ProprietarioMock({
    required this.nome,
    required this.sobrenome,
    required this.cpf,
    required this.telefone,
    required this.email,
    required this.imoveis,
    required this.dataNascimento,
  });
}

// Mocks de Exemplo
final ContratoMock mockContratoAtivo = ContratoMock(
    id: '#0025A',
    tipo: 'Aluguel',
    status: 'Vigente',
    dataInicio: '01/01/2024',
    valor: 'R\$ 3.500,00',
    imovel: 'Apto. Alameda Santos');

final ImovelMock mockImovel1 = ImovelMock(
    matricula: '123456',
    endereco: 'Av. Ibirapuera, 1000',
    statusOcupacao: 'Alugado',
    valorVenal: 'R\$ 600.000,00',
    contratos: [mockContratoAtivo]);

final ImovelMock mockImovel2 = ImovelMock(
    matricula: '789012',
    endereco: 'Rua Bela Cintra, 50',
    statusOcupacao: 'Vendido',
    valorVenal: 'R\$ 1.200.000,00',
    contratos: const []);

final ProprietarioMock mockProprietarioPrincipal = ProprietarioMock(
    nome: 'Carlos',
    sobrenome: 'Ferreira',
    cpf: '999.888.777-66',
    telefone: '(11) 97777-6666',
    email: 'carlos.ferreira@prop.com',
    dataNascimento: '20/03/1975',
    imoveis: [mockImovel1, mockImovel2]);

final List<ProprietarioMock> mockProprietariosList = [
  mockProprietarioPrincipal,
  const ProprietarioMock(
    nome: 'Alice',
    sobrenome: 'Dias',
    cpf: '111.000.222-33',
    telefone: '(11) 96666-5555',
    email: 'alice.dias@prop.com',
    dataNascimento: '10/12/1990',
    imoveis: [],
  ),
];

// **********************************************************************
//                 WIDGETS AUXILIARES REQUERIDOS
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
  // Simplificação: Removendo formatters complexos para evitar erros neste contexto
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
//                 1. PÁGINA DE LISTAGEM (ProprietarioListPage)
// **********************************************************************

class ProprietarioListPage extends StatefulWidget {
  const ProprietarioListPage({super.key});

  @override
  State<ProprietarioListPage> createState() => _ProprietarioListPageState();
}

class _ProprietarioListPageState extends State<ProprietarioListPage> {
  List<ProprietarioMock> _filteredProprietarios = mockProprietariosList;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredProprietarios = List.from(mockProprietariosList);
    _searchController.addListener(_filterList);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterList() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProprietarios = mockProprietariosList.where((prop) {
        final fullName = '${prop.nome} ${prop.sobrenome}'.toLowerCase();
        return fullName.contains(query) || prop.cpf.contains(query);
      }).toList();
    });
  }

  void _navigateToDetails(ProprietarioMock proprietario) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) =>
            ProprietarioDetailPage(proprietario: proprietario),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              "Gerenciar Proprietários",
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
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: _buildSearchField(theme, primaryColor),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final prop = _filteredProprietarios[index];
                return _buildProprietarioTile(theme, prop, primaryColor);
              },
              childCount: _filteredProprietarios.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme, Color primaryColor) {
    final isDark = theme.brightness == Brightness.dark;
    final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: fieldColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: _searchController,
        style: theme.textTheme.bodyLarge?.copyWith(color: primaryColor),
        decoration: InputDecoration(
          hintText: "Buscar por nome ou CPF...",
          border: InputBorder.none,
          prefixIcon: Icon(CupertinoIcons.search, color: Colors.grey.shade600),
          prefixIconConstraints: const BoxConstraints(minWidth: 35),
        ),
      ),
    );
  }

  Widget _buildProprietarioTile(
      ThemeData theme, ProprietarioMock proprietario, Color primaryColor) {
    final isDark = theme.brightness == Brightness.dark;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;
    final imoveisCount = proprietario.imoveis.length;

    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: primaryColor.withOpacity(0.1),
            radius: 24,
            child: Icon(CupertinoIcons.person_alt_circle_fill,
                color: primaryColor, size: 28),
          ),
          title: Text(
            "${proprietario.nome} ${proprietario.sobrenome}",
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600, color: primaryColor),
          ),
          subtitle: Text(
            "$imoveisCount Imóvei${imoveisCount != 1 ? 's' : ''} registrados",
            style: theme.textTheme.bodySmall?.copyWith(color: subtitleColor),
          ),
          trailing: const Icon(CupertinoIcons.chevron_right,
              color: Colors.grey, size: 18),
          onTap: () => _navigateToDetails(proprietario),
        ),
        Divider(
            height: 1,
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
            indent: 24,
            endIndent: 24),
      ],
    );
  }
}

// **********************************************************************
//                 2. PÁGINA DE DETALHES (ProprietarioDetailPage)
// **********************************************************************

class ProprietarioDetailPage extends StatefulWidget {
  final ProprietarioMock proprietario;

  const ProprietarioDetailPage({super.key, required this.proprietario});

  @override
  State<ProprietarioDetailPage> createState() => _ProprietarioDetailPageState();
}

class _ProprietarioDetailPageState extends State<ProprietarioDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _nomeController;
  late TextEditingController _sobrenomeController;
  late TextEditingController _telefoneController;
  late TextEditingController _emailController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // 3 Abas: Dados, Imóveis, Financeiro
    _tabController = TabController(length: 3, vsync: this);
    _nomeController = TextEditingController(text: widget.proprietario.nome);
    _sobrenomeController =
        TextEditingController(text: widget.proprietario.sobrenome);
    _telefoneController =
        TextEditingController(text: widget.proprietario.telefone);
    _emailController = TextEditingController(text: widget.proprietario.email);
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
        // Lógica de salvamento ao sair do modo de edição
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Dados do Proprietário atualizados!')));
      }
    });
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
                widget.proprietario.nome,
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
                    Tab(text: 'Imóveis'),
                    Tab(text: 'Financeiro'),
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
            _buildImoveisTab(theme, primaryColor),
            _buildFinanceiroTab(theme, primaryColor),
          ],
        ),
      ),
    );
  }

  // --- ABA 1: DADOS PESSOAIS ---
  Widget _buildDadosPessoaisTab(
      ThemeData theme, Color primaryColor, Color fieldColor) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        _buildSectionHeader(theme, "Informações Pessoais"),
        const SizedBox(height: 16),
        _buildProfileInfoTile(
          theme: theme,
          title: "CPF",
          value: widget.proprietario.cpf,
          primaryColor: primaryColor,
        ),
        const Divider(color: Colors.grey, height: 1),
        _buildProfileInfoTile(
          theme: theme,
          title: "Nascimento",
          value: widget.proprietario.dataNascimento,
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

  // --- ABA 2: IMÓVEIS ---
  Widget _buildImoveisTab(ThemeData theme, Color primaryColor) {
    final List<ImovelMock> imoveis = widget.proprietario.imoveis;
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        _buildSectionHeader(theme, "Imóveis Registrados (${imoveis.length})"),
        const SizedBox(height: 16),
        ...imoveis.map((imovel) {
          final isAlugado = imovel.statusOcupacao == 'Alugado';
          final statusColor =
              isAlugado ? CupertinoColors.activeGreen : Colors.grey;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isAlugado
                    ? Colors.green.shade50.withOpacity(0.1)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        imovel.endereco,
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
                        child: Text(imovel.statusOcupacao,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text("Matrícula: ${imovel.matricula}",
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey.shade600)),
                  Text("Valor Venal: ${imovel.valorVenal}",
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: primaryColor)),
                  const SizedBox(height: 8),
                  Text("${imovel.contratos.length} Contrato(s) ativo(s)",
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: statusColor)),
                  // TODO: Botão para Gerenciar Imóvel
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 50),
      ],
    );
  }

  // --- ABA 3: FINANCEIRO (Valores Recebidos) ---
  Widget _buildFinanceiroTab(ThemeData theme, Color primaryColor) {
    // Para fins de mock, vamos consolidar todos os pagamentos de todos os imóveis.
    // O RF06 requer: acompanhar e registrar os valores recebidos (aluguéis e multas) referentes a cada propriedade.

    // Mocks de pagamentos recebidos (Simulação)
    final List<PagamentoMock> mockReceivedPayments = [
      PagamentoMock(
          id: '#P1203',
          tipo: 'Aluguel',
          status: 'Recebido',
          dataVencimento: '05/11/2025',
          valor: 'R\$ 3.500,00',
          imovel: 'Av. Ibirapuera, 1000'),
      PagamentoMock(
          id: '#P1204',
          tipo: 'Multa',
          status: 'Recebido',
          dataVencimento: '10/10/2025',
          valor: 'R\$ 250,00',
          imovel: 'Av. Ibirapuera, 1000'),
      PagamentoMock(
          id: '#P1205',
          tipo: 'Aluguel',
          status: 'Recebido',
          dataVencimento: '05/10/2025',
          valor: 'R\$ 3.500,00',
          imovel: 'Av. Ibirapuera, 1000'),
    ];

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        _buildSectionHeader(theme,
            "Contratos Ativos (${widget.proprietario.imoveis.expand((i) => i.contratos).length})"),
        const SizedBox(height: 16),
        // Exibe contratos ativos (RF06)
        ...widget.proprietario.imoveis
            .expand((i) => i.contratos)
            .map((contrato) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _buildContratoAtivoTile(theme, primaryColor, contrato),
                ))
            .toList(),

        const SizedBox(height: 30),

        _buildSectionHeader(theme, "Valores Recebidos (Últimos Registros)"),
        const SizedBox(height: 16),
        // Exibe valores recebidos (RF06)
        ...mockReceivedPayments
            .map((pagamento) =>
                _buildPagamentoRecebidoTile(theme, primaryColor, pagamento))
            .toList(),

        const SizedBox(height: 50),
      ],
    );
  }

  // --- WIDGETS AUXILIARES DA ABA FINANCEIRA ---

  Widget _buildContratoAtivoTile(
      ThemeData theme, Color primaryColor, ContratoMock contrato) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.blue.shade50.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade400, width: 1)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${contrato.tipo} Contrato ${contrato.id}",
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: primaryColor)),
          const SizedBox(height: 4),
          Text("Imóvel: ${contrato.imovel}",
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.grey.shade600)),
          Text("Valor Mensal: ${contrato.valor}",
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: CupertinoColors.activeGreen)),
          Text("Início: ${contrato.dataInicio}",
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildPagamentoRecebidoTile(
      ThemeData theme, Color primaryColor, PagamentoMock pagamento) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(CupertinoIcons.arrow_down_circle_fill,
            color: CupertinoColors.activeGreen, size: 30),
        title: Text(pagamento.valor,
            style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: CupertinoColors.activeGreen)),
        subtitle: Text("${pagamento.tipo} - Ref. ${pagamento.imovel}",
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: Colors.grey.shade600)),
        trailing: Text(pagamento.status,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
      ),
    );
  }
}
