import 'dart:ui';
import 'package:aura_frontend/features/home/imovel_performance_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/models/imovel_model.dart';
import '../../data/models/contrato_model.dart';

import '../../data/mocks/imovel_performance_mock.dart';

// **********************************************************************
//                 FIM DOS MOCKS
// **********************************************************************

class PropertyPage extends StatelessWidget {
  const PropertyPage({super.key, required this.image});

  final String image;

  // NOVO: Função de Navegação para a Página de Performance
  void _navigateToProperityPerformance(BuildContext context) {
    // Acessa os mocks e navega
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ImovelPerformancePage(
          imovel: mockImovelPerformance,
          historicoStatus: mockStatusHistorico,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = Colors.black;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 420,
            backgroundColor: Colors.transparent,
            floating: false,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: "property-image-$hashCode",
                    child: Image.asset(
                      image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Gradiente para legibilidade
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black26,
                          Colors.transparent,
                          Colors.black45,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 16,
                    child: Row(
                      children: [
                        _buildTag(context, Icons.star_rounded, "4.9"),
                        const SizedBox(width: 8),
                        _buildTag(
                            context, Icons.apartment_rounded, "Apartamento"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            leading: _circleButton(
              context,
              icon: CupertinoIcons.back,
              onTap: () => Navigator.pop(context),
            ),
            actions: [
              // NOVO BOTÃO: Relatório de Performance
              _circleButton(
                context,
                icon: CupertinoIcons.chart_bar_alt_fill,
                onTap: () => _navigateToProperityPerformance(context),
              ),
              const SizedBox(width: 8),
              _circleButton(
                context,
                icon: CupertinoIcons.share,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _circleButton(
                context,
                icon: CupertinoIcons.heart_fill,
                color: primaryColor,
                iconColor: Colors.white,
                onTap: () {},
              ),
              const SizedBox(width: 12),
            ],
          ),

          // Conteúdo principal
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título e botão salvar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Jumeirah Village\nTriangle Dubai",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: primaryColor,
                          height: 1.2,
                        ),
                      ),
                      Icon(CupertinoIcons.bookmark,
                          color: Colors.grey.shade400),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    children: [
                      Icon(CupertinoIcons.location_solid,
                          size: 18, color: Colors.black54),
                      SizedBox(width: 6),
                      Text(
                        "Jumeirah Village Triangle Dubai",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    "Descrição do Imóvel",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Introducing a charming 3-bedroom, 2-bathroom home nestled in a peaceful suburban neighborhood. This elegant residence offers an inviting open layout with abundant natural light and premium finishes.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {},
                    child: Row(
                      children: [
                        Text(
                          "Mostrar mais",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: primaryColor),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          CupertinoIcons.arrow_right,
                          size: 20,
                          color: primaryColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Barra inferior moderna
      bottomNavigationBar: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.7),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    "\$250,000",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(CupertinoIcons.calendar),
                    label: const Text("Agendar Visita"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 14),
                      shape: const StadiumBorder(),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets auxiliares ---

  Widget _circleButton(BuildContext context,
      {required IconData icon,
      required VoidCallback onTap,
      Color? color,
      Color? iconColor}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color ?? Colors.white.withOpacity(0.7),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Icon(icon, color: iconColor ?? Colors.black, size: 20),
      ),
    );
  }

  Widget _buildTag(BuildContext context, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          )
        ],
      ),
    );
  }
}
