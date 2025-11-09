import 'package:aura_frontend/routes/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:aura_frontend/features/home/home_page.dart';
import 'package:flutter/services.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  // Função de navegação para Login (ponto de entrada após onboarding)
  void _navigateToLogin(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final secondaryColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    // Garante que a barra de status seja clara/escura (coerente com a tela)
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarColor: Colors.transparent,
    ));

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER: Identificação da Corretora ---
            Padding(
              padding: const EdgeInsets.only(top: 30, left: 30, right: 30),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(CupertinoIcons.house_fill,
                        color: isDark ? Colors.black : Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Aura Corretora",
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            // --- IMAGEM CENTRAL (Mock) ---
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 0, top: 20, bottom: 20),
                  child: Image.asset(
                    "assets/onboard.png", // Substitua pelo seu asset
                    fit: BoxFit.contain,
                    width: MediaQuery.of(context).size.width *
                        0.85, // Dá mais largura à imagem
                  ),
                ),
              ),
            ),

            // --- CONTEÚDO PRINCIPAL: Proposta de Valor ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Gestão Inteligente\ne Ativos Modernos",
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                      "Gerencie imóveis, contratos e pagamentos com precisão. A plataforma de BI e suporte que seu negócio imobiliário exige.",
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(color: secondaryColor, height: 1.5)),

                  const SizedBox(height: 40),

                  // --- BOTÕES DE AÇÃO (Cupertino Style) ---
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                        onPressed: () => _navigateToLogin(context),
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(14),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          "Iniciar Sessão",
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isDark ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                  const SizedBox(height: 20),

                  // Botão Secundário (para quem não tem conta)
                  Center(
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        // Navega para o Cadastro
                        Navigator.pushNamed(context, AppRoutes.signUp);
                      },
                      child: Text(
                        "Criar uma Conta",
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
