import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'adquirente_detail_page.dart';

class AdquirenteListPage extends StatefulWidget {
  const AdquirenteListPage({super.key});

  @override
  State<AdquirenteListPage> createState() => _AdquirenteListPageState();
}

class _AdquirenteListPageState extends State<AdquirenteListPage> {
  // Mock da lista de adquirentes (para simulação de filtro/busca)
  // ⚠️ Acesso à variável mockAdquirentesList do arquivo importado
  List<AdquirenteMock> _filteredAdquirentes = mockAdquirentesList;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ⚠️ Inicializa _filteredAdquirentes no initState se a lista for mutável
    _filteredAdquirentes = List.from(mockAdquirentesList);
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
      _filteredAdquirentes = mockAdquirentesList.where((adq) {
        final fullName = '${adq.nome} ${adq.sobrenome}'.toLowerCase();
        return fullName.contains(query) || adq.cpf.contains(query);
      }).toList();
    });
  }

  // Função de navegação para a página de detalhes
  void _navigateToDetails(AdquirenteMock adquirente) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        // ⚠️ Acesso à classe AdquirenteDetailPage do arquivo importado
        builder: (context) => AdquirenteDetailPage(adquirente: adquirente),
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
              "Gerenciar Adquirentes",
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

          // Campo de Busca (Sliver)
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: _buildSearchField(theme, primaryColor),
            ),
          ),

          // Lista de Adquirentes (Sliver)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final adquirente = _filteredAdquirentes[index];
                return _buildAdquirenteTile(theme, adquirente, primaryColor);
              },
              childCount: _filteredAdquirentes.length,
            ),
          ),

          // Espaço inferior
          const SliverToBoxAdapter(child: SizedBox(height: 30)),
        ],
      ),
    );
  }

  // Widget do Campo de Busca (Estilo Cupertino)
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

  // Widget do Item da Lista (Tile)
  Widget _buildAdquirenteTile(
      ThemeData theme, AdquirenteMock adquirente, Color primaryColor) {
    final isDark = theme.brightness == Brightness.dark;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          leading: CircleAvatar(
            backgroundColor: primaryColor.withOpacity(0.1),
            radius: 24,
            child:
                Icon(CupertinoIcons.person_fill, color: primaryColor, size: 28),
          ),
          title: Text(
            "${adquirente.nome} ${adquirente.sobrenome}",
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600, color: primaryColor),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("CPF: ${adquirente.cpf}",
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: subtitleColor)),
              Text("Crédito: ${adquirente.pontuacaoCredito}",
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: subtitleColor)),
            ],
          ),
          trailing: const Icon(CupertinoIcons.chevron_right,
              color: Colors.grey, size: 18),
          onTap: () => _navigateToDetails(adquirente),
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
