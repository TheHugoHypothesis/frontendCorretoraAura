import 'package:aura_frontend/data/models/imovel_model.dart';
import 'package:aura_frontend/features/home/imovel_filter_page.dart';
import 'package:aura_frontend/features/home/imovel_performance_page.dart';
import 'package:aura_frontend/features/home/propriety_card.dart';
import 'package:aura_frontend/features/profile/corretor_profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aura_frontend/features/home/imovel_detail_page.dart';
import 'package:aura_frontend/features/imovel_registration/imovel_registration_page.dart';
import '../../widgets/bottom_nav.dart';
import '../contract/contrato_page.dart';
import '../pagamentos/pagamentos_page.dart';
import '../../widgets/notifications_modal.dart';
import '../../data/mocks/corretor_mock.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreenContent(), // Índice 0: Home
    const ContratoContent(), // Índice 1: Contratos (Se o construtor for const)
    const PagamentoContent(), // Índice 2: Pagamentos (Se o construtor for const)
    const CorretorProfilePage(corretor: mockCorretor), // Índice 3: Perfil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: HomeBottomNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  void _showNotificationsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Permite que a folha cubra mais tela se o conteúdo for grande
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return const NotificationModalContent();
      },
    );
  }

  void _navigateToPropertyRegistration(BuildContext context) {
    // Usa Navigator.push para ir para a nova tela com animação iOS (CupertinoPageRoute)
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const PropertyRegistrationPage(),
      ),
    );
  }

  void _navigateToFilterPage(BuildContext context) async {
    // Abre a ImovelFilterPage como um modal (default do CupertinoPageRoute)
    final selectedFilters = await Navigator.push(
      context,
      CupertinoPageRoute(
        fullscreenDialog: true, // Garante que a tela abra como modal
        builder: (context) => const ImovelFilterPage(),
      ),
    );

    // ⚠️ Aqui você receberia e processaria o objeto 'filters'
    if (selectedFilters != null) {
      print("Filtros Recebidos: $selectedFilters");
      // TODO: Aplicar filtros à lista de imóveis na HomeScreenContent
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.primaryColor;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Container(
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
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Sua Localização",
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(CupertinoIcons.location_solid,
                            color: Colors.black, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "Vila Olímpia, SP",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Icon(CupertinoIcons.chevron_down, size: 14),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => _showNotificationsModal(context),
                    icon: const Icon(CupertinoIcons.bell, size: 20),
                  ),
                ),
              ],
            ),
          ),

          // SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
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
                              hintText: "Search properties...",
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
                      Text(
                        "Adicionar Imóvel",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // CONTENT (ListView de Imóveis)
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
                  // HEADER TEXT
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
                  // 🚨 CORREÇÃO 2: Chama PropertyCard corretamente (definido abaixo).
                  ...List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: PropertyCard(
                        onTap: () {
                          // Navegação para tela de DETALHES
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration:
                                  const Duration(milliseconds: 300),
                              pageBuilder: (_, __, ___) =>
                                  const PropertyPage(image: "assets/img1.jpg"),
                              transitionsBuilder:
                                  (_, animation, secondaryAnimation, child) {
                                // ... (sua lógica de transição) ...
                                const begin = Offset(0.0, 0.08);
                                const end = Offset.zero;
                                final curve = Curves.easeInOutCubic;

                                final tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));

                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: animation.drive(tween),
                                    child: child,
                                  ),
                                );
                              },
                            ),
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
