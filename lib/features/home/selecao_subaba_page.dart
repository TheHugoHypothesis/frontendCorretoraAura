import 'package:aura_frontend/features/adquirente_management/adquirente_list_page.dart';
import 'package:aura_frontend/features/profile/corretor_profile_page.dart';
import 'package:aura_frontend/features/proprietario_management/proprietario_list_page.dart';
import 'package:aura_frontend/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Exemplo: você pode receber o corretor logado via parâmetro
class SelecaoSubabaPage extends StatelessWidget {
  final dynamic corretor; // pode ser CorretorModel, se desejar tipar

  const SelecaoSubabaPage({super.key, required this.corretor});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.white;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final fieldColor = isDark ? Colors.white10 : Colors.grey.shade100;

    Widget _buildOptionTile({
      required String title,
      required String subtitle,
      required IconData icon,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: fieldColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade300,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: primaryColor, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                CupertinoIcons.chevron_right,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                size: 18,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              'Acessar Seções',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            backgroundColor: backgroundColor,
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade300,
                width: 0.0,
              ),
            ),
            automaticallyImplyLeading: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Escolha uma seção para navegar:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- BOTÃO: PERFIL DO CORRETOR ---
                  _buildOptionTile(
                    title: 'Perfil do Corretor',
                    subtitle: 'Visualize e edite suas informações pessoais',
                    icon: CupertinoIcons.person_crop_circle_fill,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.perfilCorretor,
                        arguments: corretor,
                      );
                    },
                  ),

                  // --- BOTÃO: LISTAGEM DE PROPRIETÁRIOS ---
                  _buildOptionTile(
                    title: 'Proprietários',
                    subtitle: 'Gerencie e consulte seus proprietários',
                    icon: CupertinoIcons.house_fill,
                    onTap: () {
                      Navigator.pushNamed(
                          context, AppRoutes.gerenciamentoProprietarios);
                    },
                  ),

                  // --- BOTÃO: LISTAGEM DE ADQUIRENTES ---
                  _buildOptionTile(
                    title: 'Adquirentes',
                    subtitle: 'Acompanhe seus clientes interessados',
                    icon: CupertinoIcons.person_2_fill,
                    onTap: () {
                      Navigator.pushNamed(
                          context, AppRoutes.gerenciamentoAdquirentes);
                    },
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
