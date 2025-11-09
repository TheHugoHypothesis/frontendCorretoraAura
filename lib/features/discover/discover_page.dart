import 'package:aura_frontend/features/home/propriety_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../widgets/notifications_modal.dart';
import '../../routes/app_routes.dart';

class DiscoverPage extends StatelessWidget {
  const DiscoverPage({super.key});

  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return const NotificationModalContent();
      },
    );
  }

  // 1. Navegação para Cadastro de Imóvel (Usando Rota Nomeada)
  void _navigateToPropertyRegistration(BuildContext context) {
    // Rota: /imovel/cadastro
    Navigator.pushNamed(context, AppRoutes.propertyRegistration);
  }

  // 2. Navegação para Filtros (Usando Rota Nomeada e aguardando resultado)
  void _navigateToFilterPage(BuildContext context) async {
    final selectedFilters = await Navigator.pushNamed(
      context,
      AppRoutes.filters, // Rota: /imovel/filtros
    );

    if (selectedFilters != null) {
      print("Filtros Recebidos para Aplicação: $selectedFilters");
      // TODO: Aplicar filtros à lista de imóveis aqui
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // primaryColor é usado para a cor do botão 'Adicionar Imóvel'
    final primaryColor = theme.primaryColor;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // --- HEADER (Barra Superior) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                // Ícone Esquerda (House)
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white12 : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.house_fill,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                ),

                // Logo/Título Central
                Expanded(
                  flex: 2,
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width *
                          0.45, // Ajuste de largura
                      height: 80,
                      child: Image.asset(
                        'assets/icones/aura4.png',
                        isAntiAlias: true,
                        fit: BoxFit.fitWidth,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),

                // Ícone Direita (Notificações)
                Expanded(
                  flex: 1,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white12 : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => _showNotificationsModal(context),
                        icon: const Icon(CupertinoIcons.bell, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- SEARCH BAR & BOTÕES DE AÇÃO ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                // Campo de Busca
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white10
                          : Colors.grey.shade100.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.search, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            style: theme.textTheme.bodyMedium,
                            decoration: const InputDecoration(
                              hintText: "Busque propriedades...",
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Botão de Filtro (Abre modal de filtros)
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => _navigateToFilterPage(context),
                    icon: const Icon(CupertinoIcons.slider_horizontal_3),
                  ),
                ),

                const SizedBox(width: 12),

                // Botão Adicionar Imóvel (Navegação Limpa)
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () => _navigateToPropertyRegistration(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.add,
                          size: 20, color: Colors.white),
                      const SizedBox(width: 4),
                      Text("Adicionar Imóvel",
                          style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.black : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: ListView(
                children: [
                  // Título principal
                  Text(
                    "Descubra\nlistagens modernas",
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // PROPERTY CARDS
                  ...List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: PropertyCard(
                        // ⚠️ Substitua 'PropertyPage' por sua rota nomeada real
                        onTap: () {
                          // Navegação limpa para Detalhes, passando um ID/Argumento
                          Navigator.pushNamed(
                            context,
                            AppRoutes
                                .propertyDetails, // Rota para ImovelDetailPage
                            arguments: 'ID_DO_IMOVEL_$index',
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
