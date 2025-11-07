import 'package:aura_frontend/screens/corretor_profile_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aura_frontend/screens/property_page.dart';
import 'package:aura_frontend/screens/propriety_registration_page.dart';
import '../widgets/bottom_nav.dart';
import 'contrato_page.dart';
import 'pagamentos_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  
  @override
  State<HomePage> createState() => _HomePageState();
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

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreenContent(), // Índice 0: Home
    const ContratoContent(), // Índice 1: Contratos (Se o construtor for const)
    const PagamentoContent(), // Índice 2: Pagamentos (Se o construtor for const)
    const CorretorProfilePage(), // Índice 3: Perfil
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
                    onPressed: () {},
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
                      const Icon(CupertinoIcons.add, size: 20, color: Colors.white),
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
          child: Text("Property Card - Clique para Detalhes",
              style: TextStyle(fontWeight: FontWeight.bold)),
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

// --- Estrutura Mock de Dados ---
class NotificationItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String time;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.time,
  });
}

final List<NotificationItem> initialMockNotifications = [
  NotificationItem(
    icon: CupertinoIcons.doc_fill,
    title: 'Contrato Vencendo',
    subtitle: 'O contrato do imóvel #123456 (Rua X) vence em 5 dias.',
    color: Colors.red.shade700,
    time: '2 min atrás',
  ),
  NotificationItem(
    icon: CupertinoIcons.money_dollar_circle_fill,
    title: 'Pagamento Atrasado',
    subtitle: 'O inquilino do imóvel #789012 está com aluguel pendente.',
    color: Colors.orange.shade700,
    time: '1 hora atrás',
  ),
  NotificationItem(
    icon: CupertinoIcons.person_alt_circle_fill,
    title: 'Novo Lead',
    subtitle: 'Novo adquirente interessado em imóveis comerciais.',
    color: Colors.blue.shade700,
    time: 'Ontem',
  ),
  NotificationItem(
    icon: CupertinoIcons.house_fill,
    title: 'Novo Imóvel Cadastrado',
    subtitle: 'Imóvel residencial na região do Itaim Bibi disponível.',
    color: Colors.green.shade700,
    time: '3 dias atrás',
  ),
];

class NotificationModalContent extends StatefulWidget {
  const NotificationModalContent({super.key});

  @override
  State<NotificationModalContent> createState() =>
      _NotificationModalContentState();
}

class _NotificationModalContentState extends State<NotificationModalContent> {
  // 1. Lista de avisos agora é mutável (State)
  late List<NotificationItem> _notifications;

  @override
  void initState() {
    super.initState();
    // Cria uma cópia da lista mock para poder modificá-la
    _notifications = List.from(initialMockNotifications);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final redColor = Colors.red.shade700;

    return Container(
      // Altura ajustável: Se não houver avisos, a altura será mínima.
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar (linha de arrasto)
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(height: 16),

          // Título
          Text(
            "Avisos & Alertas (${_notifications.length})",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // 2. Lista de Notificações (Expandida para permitir rolagem)
          Expanded(
            child: _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(CupertinoIcons.bell_slash,
                            size: 40, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          "Nenhum aviso pendente.",
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final item = _notifications[index];

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Dismissible(
                          // Chave única é obrigatória
                          key: Key(item.title + item.time),
                          direction: DismissDirection
                              .startToEnd, // Permite deslizar apenas da esquerda para a direita

                          // Fundo ao deslizar (Estilo "Apple Like" - Fundo Vermelho)
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            decoration: BoxDecoration(
                              color: redColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(CupertinoIcons.trash_fill,
                                color: Colors.white),
                          ),

                          // Ocorre ao dispensar o item
                          onDismissed: (direction) {
                            // Exibe um Snackbar (Opcional)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("${item.title} dispensado.")),
                            );

                            // Remove o item da lista de estado
                            setState(() {
                              _notifications.removeAt(index);
                            });
                          },

                          // Conteúdo do aviso (Mantido da implementação anterior)
                          child: _buildNotificationTileContent(
                              theme, item, isDark, primaryColor),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Novo Widget Auxiliar para o conteúdo do Tile (para uso dentro do Dismissible)
  Widget _buildNotificationTileContent(
      ThemeData theme, NotificationItem item, bool isDark, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.black
            : Colors
                .white, // Fundo branco/preto sólido para cobrir o fundo vermelho
        border:
            Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícone com cor de destaque
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                    Text(
                      item.time,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
