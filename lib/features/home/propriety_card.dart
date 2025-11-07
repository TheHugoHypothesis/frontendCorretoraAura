import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PropertyCard extends StatelessWidget {
  final VoidCallback onTap;
  // Se o card for dinâmico no futuro: final ImovelMock imovel;

  const PropertyCard(
      {required this.onTap,
      super.key}); // Adicionar 'required this.imovel' se for dinâmico

  @override
  Widget build(BuildContext context) {
    // Implementação mock (simulada) que estava no final da HomePage
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
