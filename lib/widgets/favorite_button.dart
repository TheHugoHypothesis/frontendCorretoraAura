import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  bool _isFavorited = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Configura a animação de pulso (rápida e suave)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    // 1. Inicia a animação de encolher
    _controller.forward().then((_) {
      // 2. Troca o estado no meio da animação
      setState(() {
        _isFavorited = !_isFavorited;
      });
      // 3. Volta ao tamanho original (efeito de bounce)
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFavorite,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: 42,
        height: 42,
        // O Fundo fica neutro (Branco levemente translúcido ou Sólido)
        decoration: BoxDecoration(
          color:
              Colors.white.withOpacity(0.9), // Leve transparência estilo Glass
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Icon(
            // Troca o ícone: Borda se false, Preenchido se true
            _isFavorited ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
            // Troca a cor: Vermelho Sistema se true, Preto se false
            color: _isFavorited ? CupertinoColors.systemRed : Colors.black,
            size: 22, // Tamanho levemente maior para destaque
          ),
        ),
      ),
    );
  }
}
