import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// --- Dependências do PDF e Arquivos ---
import 'package:path_provider/path_provider.dart'; // Para getApplicationDocumentsDirectory
import 'package:pdf/pdf.dart'; // Para PdfColors
import 'package:pdf/widgets.dart' as pw; // Para construção do PDF
import 'package:intl/intl.dart'; // Para DateFormat
import 'package:open_filex/open_filex.dart'; // Para abrir o arquivo

import '../../data/models/contrato_model.dart';
import '../../data/models/imovel_model.dart';
import '../../data/mocks/imovel_performance_mock.dart';

// **********************************************************************
//               CLASSE PRINCIPAL DE PERFORMANCE
// **********************************************************************

class ImovelPerformancePage extends StatefulWidget {
  final ImovelModel imovel;
  final List<String> historicoStatus;

  const ImovelPerformancePage({
    super.key,
    required this.imovel,
    required this.historicoStatus,
  });

  @override
  State<ImovelPerformancePage> createState() => _ImovelPerformancePageState();
}

class _ImovelPerformancePageState extends State<ImovelPerformancePage> {
  // --- LÓGICA DE CÁLCULO DE RELATÓRIO (Mocked) ---
  Map<String, String> _calculatePerformanceMetrics() {
    final allContracts = widget.imovel.contratos;
    final rentalContracts = allContracts.where((c) => c.tipo == 'Aluguel');

    final lastRentalValue =
        rentalContracts.isNotEmpty ? rentalContracts.last.valor : 'R\$ 0,00';

    return {
      'totalContratos': allContracts.length.toString(),
      'valorMedio': lastRentalValue,
    };
  }

  // --- ORQUESTRADOR DE EXPORTAÇÃO ---
  void _exportRelatorioPerformance() async {
    showCupertinoModalPopup(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CupertinoAlertDialog(
        title: Text("Exportando Relatório"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10),
            CupertinoActivityIndicator(radius: 15),
            SizedBox(height: 10),
            Text("Gerando PDF de Performance..."),
          ],
        ),
      ),
    );

    try {
      await _gerarRelatorioDePerformance(widget.imovel, widget.historicoStatus);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Relatório exportado e aberto com sucesso!'),
            backgroundColor: CupertinoColors.activeGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Falha ao exportar PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- GERAÇÃO REAL DO PDF ---
  Future<void> _gerarRelatorioDePerformance(
      ImovelModel imovel, List<String> historicoStatus) async {
    final pdf = pw.Document();
    final dataAtual = DateTime.now();
    final dataFormatada = DateFormat('dd-MM-yyyy').format(dataAtual);

    final metrics = _calculatePerformanceMetrics();

    final historicoData = historicoStatus.map((statusEntry) {
      final parts = statusEntry.split(': ');
      return [parts[0], parts.length > 1 ? parts[1] : 'Status Indisponível'];
    }).toList();

    historicoData.insert(0, ['Data', 'Evento / Valor']);

    // Montagem do PDF
    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              '🏠 Relatório de Performance do Imóvel',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text('Imóvel: ${imovel.endereco}',
              style: const pw.TextStyle(fontSize: 12)),
          pw.Text('Matrícula: ${imovel.matricula}',
              style: const pw.TextStyle(fontSize: 12)),
          pw.Text(
              'Data de emissão: ${DateFormat('dd/MM/yyyy').format(dataAtual)}',
              style: const pw.TextStyle(fontSize: 12)),

          pw.SizedBox(height: 20),

          // --- RESUMO FINANCEIRO E DE OCUPAÇÃO ---
          pw.Header(
              level: 1,
              child: pw.Text('Resumo de Performance',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),

          pw.SizedBox(height: 10),

          _buildPdfMetricsTable(
            metrics,
            imovel.statusOcupacao,
            imovel.valorVenal,
            primaryColor: PdfColors.black,
          ),

          pw.SizedBox(height: 30),

          // --- TABELA DE HISTÓRICO ---
          pw.Header(
              level: 1,
              child: pw.Text('Histórico Cronológico e Contratual',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),

          pw.Table.fromTextArray(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            data: historicoData,
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 11),
            rowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
          ),

          pw.SizedBox(height: 30),

          pw.Text(
            'Fim do Relatório.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ],
      ),
    );

    // Salvar o arquivo
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        "${dir.path}/relatorio_imovel_${imovel.matricula}_$dataFormatada.pdf");
    await file.writeAsBytes(await pdf.save());

    // Abrir o arquivo automaticamente
    await OpenFilex.open(file.path);
  }

  // **********************************************************************
  //                 WIDGETS AUXILIARES (AGORA MÉTODOS DA CLASSE)
  // **********************************************************************

  // WIDGET AUXILIAR 1: Tabela de Métricas para PDF
  pw.Widget _buildPdfMetricsTable(
      Map<String, String> metrics, String status, String valorVenal,
      {required PdfColor primaryColor}) {
    final metricData = [
      ['Status Atual', status],
      ['Valor Venal', valorVenal],
      ['Total Contratos', metrics['totalContratos']!],
      ['Valor Médio (Aluguel)', metrics['valorMedio']!],
    ];

    return pw.Table.fromTextArray(
      border: null,
      data: metricData,
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(3)
      },
      cellAlignment: pw.Alignment.centerLeft,
      cellStyle: pw.TextStyle(fontSize: 12, color: primaryColor),
      rowDecoration: const pw.BoxDecoration(
          border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5))),
    );
  }

  // WIDGET AUXILIAR 2: Cabeçalho de Seção
  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(title,
          style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700, color: theme.colorScheme.onSurface)),
    );
  }

  // WIDGET AUXILIAR 3: Tile de Informação
  Widget _buildProfileInfoTile({
    required ThemeData theme,
    required String title,
    required String value,
    required Color primaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title,
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey)),
        Text(value,
            style: theme.textTheme.bodyLarge
                ?.copyWith(fontWeight: FontWeight.w500, color: primaryColor)),
      ]),
    );
  }

  // WIDGET AUXILIAR 4: Tile de Status/Métrica Visual
  Widget _buildStatusTile({
    required ThemeData theme,
    required String title,
    required String value,
    required Color color,
  }) {
    final primaryColor =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: theme.textTheme.bodyMedium?.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black;
    final metrics = _calculatePerformanceMetrics();

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(
              "Histórico do Imóvel",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            backgroundColor: isDark ? Colors.black : Colors.white,
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white12 : Colors.grey.shade300,
                width: 0.0,
              ),
            ),
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              child: Icon(CupertinoIcons.chevron_left, color: primaryColor),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- INFORMAÇÕES BÁSICAS DO IMÓVEL ---
                  _buildSectionHeader(theme, "Imóvel e Status Atual"),
                  const SizedBox(height: 16),

                  // Status Atual e Valor Venal
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatusTile(
                          theme: theme,
                          title: "Status",
                          value: widget.imovel.statusOcupacao,
                          color: widget.imovel.statusOcupacao == 'Disponível'
                              ? Colors.orange.shade700
                              : CupertinoColors.activeGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatusTile(
                          theme: theme,
                          title: "Valor Venal",
                          value: widget.imovel.valorVenal,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Endereço e Matrícula (Estilo Tile)
                  _buildProfileInfoTile(
                    theme: theme,
                    title: "Endereço",
                    value: widget.imovel.endereco,
                    primaryColor: primaryColor,
                  ),
                  const Divider(color: Colors.grey, height: 1),
                  _buildProfileInfoTile(
                    theme: theme,
                    title: "Matrícula",
                    value: widget.imovel.matricula,
                    primaryColor: primaryColor,
                  ),
                  const Divider(color: Colors.grey, height: 1),

                  const SizedBox(height: 40),

                  // --- ANÁLISE DE PERFORMANCE ---
                  _buildSectionHeader(theme, "Relatório de Performance (BI)"),
                  const SizedBox(height: 16),

                  // Métrica de Contratos
                  _buildStatusTile(
                    theme: theme,
                    title: "Total de Contratos Registrados",
                    value: metrics['totalContratos']!,
                    color: primaryColor,
                  ),
                  const SizedBox(height: 12),

                  // Métrica de Aluguel Médio
                  _buildStatusTile(
                    theme: theme,
                    title: "Valor Médio Praticado (Aluguel)",
                    value: metrics['valorMedio']!,
                    color: CupertinoColors.activeGreen,
                  ),

                  const SizedBox(height: 40),

                  // --- HISTÓRICO DE STATUS/OCUPAÇÃO ---
                  _buildSectionHeader(theme, "Histórico Cronológico"),
                  const SizedBox(height: 16),

                  ...widget.historicoStatus.map((statusEntry) {
                    final parts = statusEntry.split(': ');
                    final date = parts[0];
                    final status = parts.length > 1 ? parts[1] : '';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(date,
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey)),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Text(
                              status,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                                color: primaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  const SizedBox(height: 50),

                  // --- BOTÃO DE EXPORTAÇÃO PDF ---
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: CupertinoButton(
                      color: Colors.blue.shade700,
                      onPressed: _exportRelatorioPerformance,
                      borderRadius: BorderRadius.circular(14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(CupertinoIcons.doc_text,
                              color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            "Exportar Relatório em PDF",
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
