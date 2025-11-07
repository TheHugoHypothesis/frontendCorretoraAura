import 'package:aura_frontend/data/models/proprietario_model.dart';
import 'package:aura_frontend/features/proprietario_management/proprietario_detail_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/mocks/proprietarios_mock.dart';

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
  List<ProprietarioModel> _filteredProprietarios = mockProprietariosList;
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

  void _navigateToDetails(ProprietarioModel proprietario) {
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
      ThemeData theme, ProprietarioModel proprietario, Color primaryColor) {
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
