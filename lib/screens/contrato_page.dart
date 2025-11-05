import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ContratoPage extends StatelessWidget {
  const ContratoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Contratos",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: ListView(
          children: [
            // ====== Gráfico de Fluxo Financeiro ======
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
                color: isDark ? Colors.white10 : Colors.grey.shade100,
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
                      color: Colors.black,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.black.withOpacity(0.1),
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

            // ====== Cards de Status ======
            Text(
              "Resumo de Contratos",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _statusCard(context, "Ativos", "12", Colors.black),
                const SizedBox(width: 12),
                _statusCard(context, "Vencendo", "3", Colors.amber),
                const SizedBox(width: 12),
                _statusCard(context, "Atrasados", "1", Colors.redAccent),
              ],
            ),

            const SizedBox(height: 32),

            // ====== Lista de Contratos ======
            Text(
              "Contratos Recentes",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: _contractTile(context,
                    title: "Apartamento ${index + 1}B - Zona Sul",
                    owner: "João Oliveira",
                    tenant: "Maria Souza",
                    dueDate: "15 Nov 2025",
                    value: "R\$ 2.500,00",
                    statusColor: Colors.black),
              ),
            ),
          ],
        ),
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

  Widget _contractTile(BuildContext context,
      {required String title,
      required String owner,
      required String tenant,
      required String dueDate,
      required String value,
      required Color statusColor}) {
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
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          "Locador: $owner\nInquilino: $tenant\nVencimento: $dueDate",
          style: const TextStyle(height: 1.4, color: Colors.grey),
        ),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
