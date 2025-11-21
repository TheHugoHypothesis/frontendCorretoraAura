import 'dart:ui';
import 'package:aura_frontend/features/home/imovel_performance_page.dart';
import 'package:aura_frontend/features/imovel_details/imovel_history_page.dart';
import 'package:aura_frontend/widgets/favorite_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/models/imovel_model.dart';
import '../../data/models/contrato_model.dart';
import 'package:intl/intl.dart';

import '../../data/mocks/imovel_performance_mock.dart';

// **********************************************************************
//                 FIM DOS MOCKS
// **********************************************************************

class PropertyPage extends StatelessWidget {
  final ImovelModel imovel;

  const PropertyPage({super.key, required this.imovel});

  void _navigateToHistory(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ImovelHistoryPage(matricula: imovel.matricula),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = Colors.black;

    // Formatador de Moeda
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    // Tenta converter o valor venal (string) para double para formatação limpa, ou usa a string direta
    String precoFormatado = imovel.valorVenalFormatado;

    // Tag Hero Única
    final heroTag = "property-image-${imovel.matricula}";

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
                  // IMAGEM DO IMÓVEL (Hero)
                  Hero(
                    tag: heroTag,
                    child: _buildImovelImage(imovel.profileImageUrl),
                  ),

                  // Gradiente
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black26,
                          Colors.transparent,
                          Colors.black45
                        ],
                      ),
                    ),
                  ),

                  // Tags (Tipo e Avaliação)
                  Positioned(
                    bottom: 20,
                    left: 16,
                    child: Row(
                      children: [
                        _buildTag(context, Icons.star_rounded,
                            "5.0"), // Mock de avaliação
                        const SizedBox(width: 8),
                        _buildTag(context, Icons.apartment_rounded,
                            imovel.tipo ?? "Imóvel"),
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
              _circleButton(
                context,
                icon: CupertinoIcons.time,
                onTap: () => _navigateToHistory(context),
              ),
              const SizedBox(width: 8),
              const FavoriteButton(),
              const SizedBox(width: 12),
            ],
          ),

          // CONTEÚDO PRINCIPAL
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título (Endereço Principal)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          imovel.numero.isNotEmpty
                              ? "${imovel.logradouro}, ${imovel.numero}"
                              : imovel.logradouro,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: primaryColor,
                            height: 1.2,
                            fontSize: 24,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      Icon(CupertinoIcons.bookmark,
                          color: Colors.grey.shade400),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Localização Completa
                  Row(
                    children: [
                      const Icon(CupertinoIcons.location_solid,
                          size: 18, color: Colors.black54),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          imovel.enderecoCompleto, // Endereço completo
                          style: const TextStyle(color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Características
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFeatureInfo(
                          Icons.bed, "${imovel.numQuartos ?? 0} Quartos"),
                      _buildFeatureInfo(
                          Icons.square_foot, "${imovel.metragem ?? 0} m²"),
                      _buildFeatureInfo(
                          Icons.build, "${imovel.numReformas ?? 0} Reformas"),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Text(
                    "Descrição do Imóvel",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Este imóvel está atualmente com status: ${imovel.statusOcupacao}. Localizado em uma região privilegiada, ideal para ${imovel.finalidade}.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Comodidades (Chips)
                  if (imovel.comodidades.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text("Comodidades",
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: imovel.comodidades
                          .map((c) =>
                              _buildTag(context, Icons.check, c, isDark: true))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // BARRA INFERIOR (PREÇO E AÇÃO)
      bottomNavigationBar: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Valor Total",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    precoFormatado,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(CupertinoIcons.calendar),
                label: const Text("Agendar Visita"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildImovelImage(String? url) {
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Image.asset("assets/img1.jpg", fit: BoxFit.cover),
      );
    }
    return Image.asset("assets/img1.jpg",
        fit: BoxFit.cover); // Placeholder padrão
  }

  Widget _buildFeatureInfo(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }

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
                offset: const Offset(0, 3))
          ],
        ),
        child: Icon(icon, color: iconColor ?? Colors.black, size: 20),
      ),
    );
  }

  Widget _buildTag(BuildContext context, IconData icon, String label,
      {bool isDark = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey.shade200 : Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isDark ? Colors.black : Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
                color: isDark ? Colors.black : Colors.white, fontSize: 14),
          )
        ],
      ),
    );
  }
}
