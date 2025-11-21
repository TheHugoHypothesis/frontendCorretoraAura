import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Gráfico mantido
import 'package:intl/intl.dart';

// Imports do projeto
import 'package:aura_frontend/features/contract/contract_registration_page.dart';
import 'package:aura_frontend/features/contract/contract_details_page.dart';
import 'package:aura_frontend/data/models/contrato_model.dart';
import 'package:aura_frontend/core/repositorios/contrato_repository.dart';

class ContratoListPage extends StatefulWidget {
  const ContratoListPage({super.key});

  @override
  State<ContratoListPage> createState() => _ContratoListPageState();
}

class _ContratoListPageState extends State<ContratoListPage> {
  final ContratosRepository _repository = ContratosRepository();

  // Estado dos Dados
  List<ContratoModel> _contratosRecentes = [];
  bool _isLoading = true;

  // Estatísticas (Resumo)
  int _ativos = 0;
  int _vencendo = 0;
  int _atrasados = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      // Busca em paralelo para performance
      final results = await Future.wait([
        _repository.getAlugueisAtivos(),
        _repository.getContratosNoPrazo(), // Vencendo
        // _repository.getContratosAtrasados(), // Se tiver endpoint
      ]);

      if (mounted) {
        setState(() {
          final ativosList = results[0] as List<ContratoModel>;
          final vencendoList = results[1] as List;

          // Atualiza lista principal e contadores
          _contratosRecentes = ativosList; // Ou uma combinação
          _ativos = ativosList.length;
          _vencendo = vencendoList.length;
          _atrasados = 0; // Mock ou implementar lógica

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        print("Erro ao carregar: $e");
      }
    }
  }

  void _navigateToContractRegistration(BuildContext context) async {
    await Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => const ContractRegistrationPage(),
      ),
    );
    _fetchData(); // Recarrega ao voltar
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    // Formatadores para exibição
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SafeArea(
      child: Column(
        children: [
          // ===== Header com botão (MANTIDO IGUAL) =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Contratos",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                CupertinoButton(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(12),
                  onPressed: () => _navigateToContractRegistration(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(CupertinoIcons.add,
                          size: 20, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        "Criar Contrato",
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

          // ===== Conteúdo =====
          Expanded(
            child: _isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchData,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      children: [
                        // ===== Gráfico (MANTIDO IGUAL) =====
                        Text(
                          "Fluxo Financeiro",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color:
                                isDark ? Colors.white10 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  isCurved: true,
                                  color: primaryColor,
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: primaryColor.withOpacity(0.1),
                                  ),
                                  spots: const [
                                    FlSpot(0, 2),
                                    FlSpot(1, 2.5),
                                    FlSpot(2, 3.1),
                                    FlSpot(3, 2.8),
                                    FlSpot(4, 3.6),
                                    FlSpot(5, 3.2),
                                    FlSpot(6, 4.2),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ===== Status (DADOS REAIS) =====
                        Text(
                          "Resumo de Contratos",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _statusCard(
                                context, "Ativos", "$_ativos", primaryColor),
                            const SizedBox(width: 12),
                            _statusCard(context, "Vencendo", "$_vencendo",
                                Colors.amber),
                            const SizedBox(width: 12),
                            _statusCard(context, "Atrasados", "$_atrasados",
                                Colors.redAccent),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // ===== Lista (DADOS REAIS) =====
                        Text(
                          "Contratos Recentes",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (_contratosRecentes.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Center(
                                child: Text("Nenhum contrato encontrado.")),
                          )
                        else
                          ..._contratosRecentes.map((contrato) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14.0),
                              child: _contractTile(
                                context,
                                contrato: contrato,
                                statusColor: primaryColor,
                                dateFormat: dateFormat,
                                currencyFormat: currencyFormat,
                              ),
                            );
                          }).toList(),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // ======= Widgets auxiliares (MANTIDOS IGUAIS) =======
  Widget _statusCard(
      BuildContext context, String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contractTile(
    BuildContext context, {
    required ContratoModel contrato,
    required Color statusColor,
    // Argumentos opcionais para formatação
    required DateFormat dateFormat,
    required NumberFormat currencyFormat,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ContractDetailsPage(contrato: contrato),
            ),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(CupertinoIcons.doc_plaintext, color: statusColor),
        ),
        title: Text(
          "Contrato #${contrato.codigo}", // Exibe o código real
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "Imóvel: ${contrato.matriculaImovel}\n" // Exibe a matrícula
          "Início: ${dateFormat.format(contrato.dataInicio)}", // Data real
          style: const TextStyle(height: 1.4, color: Colors.grey),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              currencyFormat.format(contrato.valor), // Valor real
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            // Status ou Tipo
            Text(
              contrato.tipo,
              style: TextStyle(fontSize: 12, color: statusColor),
            ),
          ],
        ),
      ),
    );
  }
}
