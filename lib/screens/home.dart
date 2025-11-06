import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aura_frontend/screens/property_page.dart';
import '../widgets/bottom_nav.dart';
import 'contrato_page.dart'; 
import 'pagamentos_page.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;


  final List<Widget> _screens = [
    const HomeScreenContent(),      // Índice 0: Home
    const ContratoContent(),        // Índice 1: Contratos (Se o construtor for const)
    const PagamentoContent(),       // Índice 2: Pagamentos (Se o construtor for const)
    const Center(child: Text("Perfil Content")), // Índice 3: Perfil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          // HEADER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                // ... (seu código de Header) ...
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
                      "Your location",
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
                          "San Francisco, CA",
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
                    onPressed: () {},
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
                    onPressed: () {},
                    icon: const Icon(CupertinoIcons.slider_horizontal_3),
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
                    "Discover\nmodern listings",
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
                              transitionDuration: const Duration(milliseconds: 300),
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

// ----------------------------------------------------
// 4. Definição do Widget PropertyCard (para resolver o erro)
// ----------------------------------------------------
// Assumindo uma estrutura básica de cartão de imóvel, baseada no uso.
class PropertyCard extends StatelessWidget {
  final VoidCallback onTap;
  const PropertyCard({required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    // Implementação mock (simulada) para permitir a compilação
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text("Property Card - Clique para Detalhes", style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------------------------------------------
// 💡 Ação Necessária do Usuário:
// -------------------------------------------------------------------------------------------------------
// Para que o erro de 'PagamentoContent' seja completamente resolvido,
// você precisa garantir que o arquivo 'pagamentos_page.dart' exporte o widget 'PagamentoContent'
// e que seu construtor seja 'const', assim:
//
// class PagamentoContent extends StatelessWidget {
//   const PagamentoContent({super.key});
//   // ...
// }
//
// E o mesmo para ContratoContent.