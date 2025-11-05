import 'dart:ui';
import 'package:aura_frontend/screens/contrato_page.dart';
import 'package:aura_frontend/screens/home.dart';
import 'package:aura_frontend/screens/pagamentos_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeBottomNavBar extends StatefulWidget {
  const HomeBottomNavBar({super.key});

  @override
  State<HomeBottomNavBar> createState() => _HomeBottomNavBarState();
}

class _HomeBottomNavBarState extends State<HomeBottomNavBar> {
  int _selectedIndex = 0;

  final List<IconData> _icons = [
    CupertinoIcons.house, // outline (não filled)
    CupertinoIcons.doc_text, // outline
    CupertinoIcons.money_dollar, // outline
    CupertinoIcons.person, // outline
  ];

  final List<String> _labels = [
    'Home',
    'Contr',
    'Pagam',
    'Perfil',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_icons.length, (index) {
              final isActive = _selectedIndex == index;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = index);

                    Widget page;
                    switch (index) {
                      case 0:
                        page = const HomePage();
                        break;
                      case 1:
                        page = const ContratoPage();
                        break;
                      case 2:
                        page = const PagamentosPage();
                        break;
                      default:
                        page = const HomePage();
                    }

                    Navigator.pushReplacement(
                      context,
                      CupertinoPageRoute(builder: (_) => page),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8), // 🔹 menor padding
                    child: SizedBox(
                      height: 70,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? (isDark
                                      ? Colors.white.withOpacity(0.12)
                                      : Colors.black.withOpacity(0.08))
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.15)
                                            : Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Icon(
                              _icons[index],
                              color: isActive
                                  ? (isDark ? Colors.white : Colors.black)
                                  : Colors.grey,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 4), // 🔹 ligeiramente menor
                          AnimatedOpacity(
                            opacity: isActive ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _labels[index],
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodySmall?.copyWith(
                                height: 1.0, // 🔹 estabiliza altura da linha
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
