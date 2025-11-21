import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

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

  List<ContratoModel> _contratosList = [];
  bool _isLoading = true;

  // Estatísticas
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
      final results = await Future.wait([
        _repository.getDashboardStats(),
        _repository.getContratosGerais(),
      ]);

      if (mounted) {
        setState(() {
          final stats = results[0] as Map<String, dynamic>;
          _ativos = stats['ativos'] ?? 0;
          _vencendo = stats['vencendo'] ?? 0;
          _atrasados = stats['atrasados'] ?? 0;

          _contratosList = results[1] as List<ContratoModel>;

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint("Erro ao carregar dados: $e");
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
    _fetchData();
  }

  // --- LÓGICA DO GRÁFICO ---

  // Gera os pontos do gráfico (Últimos 6 meses)
  List<FlSpot> _getChartSpots() {
    if (_contratosList.isEmpty) return [const FlSpot(0, 0), const FlSpot(5, 0)];

    final now = DateTime.now();
    final List<FlSpot> spots = [];

    // Itera pelos últimos 6 meses (0 a 5)
    for (int i = 0; i < 6; i++) {
      // Começa do mês mais antigo (5 meses atrás) até o atual
      final targetDate = DateTime(now.year, now.month - (5 - i));

      // Soma valores dos contratos criados neste mês/ano
      double monthlyTotal = 0;
      for (var contrato in _contratosList) {
        if (contrato.dataInicio.month == targetDate.month &&
            contrato.dataInicio.year == targetDate.year) {
          monthlyTotal += contrato.valor;
        }
      }
      spots.add(FlSpot(i.toDouble(), monthlyTotal));
    }
    return spots;
  }

  // Gera os títulos dos meses para o Eixo X
  Widget _bottomTitleWidgets(double value, TitleMeta meta, bool isDark) {
    final now = DateTime.now();
    // Calcula o mês correspondente ao índice do gráfico
    final date = DateTime(now.year, now.month - (5 - value.toInt()));
    final String monthName =
        DateFormat('MMM', 'pt_BR').format(date).toUpperCase();

    return SideTitleWidget(
      meta: meta,
      space: 4,
      child: Text(
        monthName,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10,
          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    final currencyFormat = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SafeArea(
      child: Column(
        children: [
          // HEADER
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

          // CONTEÚDO
          Expanded(
            child: _isLoading
                ? const Center(child: CupertinoActivityIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchData,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      children: [
                        // --- GRÁFICO FINANCEIRO ---
                        Text(
                          "Novos Contratos (6 Meses)",
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 220,
                          decoration: BoxDecoration(
                            color:
                                isDark ? Colors.white10 : Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: isDark
                                    ? Colors.white12
                                    : Colors.grey.shade200),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 24, 24, 10),
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: false),
                              titlesData: FlTitlesData(
                                show: true,
                                rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                // Eixo Y (Valores) - Simplificado
                                leftTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                // Eixo X (Meses)
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    interval: 1,
                                    getTitlesWidget: (value, meta) =>
                                        _bottomTitleWidgets(
                                            value, meta, isDark),
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _getChartSpots(),
                                  isCurved: true,
                                  color: primaryColor,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: const FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    // Gradiente suave
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        primaryColor.withOpacity(0.2),
                                        primaryColor.withOpacity(0.0),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              // Tooltip ao tocar no gráfico
                              lineTouchData: LineTouchData(
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipColor: (touchedSpot) => isDark
                                      ? Colors.grey.shade800
                                      : Colors.white,
                                  getTooltipItems:
                                      (List<LineBarSpot> touchedBarSpots) {
                                    return touchedBarSpots.map((barSpot) {
                                      return LineTooltipItem(
                                        currencyFormat.format(barSpot.y),
                                        TextStyle(
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // --- CARDS DE STATUS ---
                        Text(
                          "Resumo de Contratos",
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _statusCard(
                                context, "Ativos", "$_ativos", primaryColor),
                            const SizedBox(width: 12),
                            _statusCard(context, "Vencendo", "$_vencendo",
                                Colors.amber.shade700),
                            const SizedBox(width: 12),
                            _statusCard(context, "Atrasados", "$_atrasados",
                                Colors.red.shade700),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // --- LISTA DE CONTRATOS ---
                        Text(
                          "Últimos Registros",
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),

                        if (_contratosList.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(CupertinoIcons.doc_text_search,
                                      size: 40, color: Colors.grey.shade400),
                                  const SizedBox(height: 10),
                                  const Text("Nenhum contrato encontrado.",
                                      style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          )
                        else
                          ..._contratosList.take(10).map((contrato) {
                            // Mostra apenas os 10 últimos na lista inicial
                            final statusColor = contrato.tipo == 'Aluguel'
                                ? primaryColor
                                : Colors.orange;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14.0),
                              child: _contractTile(
                                context,
                                contrato: contrato,
                                statusColor: statusColor,
                                currencyFormat: currencyFormat,
                                dateFormat: dateFormat,
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

  Widget _statusCard(
      BuildContext context, String label, String value, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white70 : Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  Widget _contractTile(BuildContext context,
      {required ContratoModel contrato,
      required Color statusColor,
      required NumberFormat currencyFormat,
      required DateFormat dateFormat}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
        border:
            Border.all(color: isDark ? Colors.white12 : Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => ContractDetailsPage(contrato: contrato))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(CupertinoIcons.doc_text, color: statusColor, size: 20),
        ),
        title: Text(
          "Contrato #${contrato.codigo}",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            "Imóvel: ${contrato.matriculaImovel}\nInício: ${dateFormat.format(contrato.dataInicio)}",
            style:
                const TextStyle(height: 1.4, fontSize: 12, color: Colors.grey),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(currencyFormat.format(contrato.valor),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(contrato.status,
                style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
