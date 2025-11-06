import 'dart:ui';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/pdf.dart';

// 🚨 MUDANÇA DE NOME: De PagamentosPage para PagamentoContent 🚨
// Isso resolve o erro de compilação na HomePage e remove o Scaffold/AppBar.

class PagamentoContent extends StatefulWidget {
  const PagamentoContent({super.key}); // Use 'const' no construtor

  @override
  State<PagamentoContent> createState() => _PagamentoContentState();
}

class _PagamentoContentState extends State<PagamentoContent> {
  int _filterTipoIndex = 0;
  int _filterStatusIndex = 0;
  String _ordenarPor = 'data';

  // Seus dados e lógica de estado permanecem aqui
  final List<Map<String, dynamic>> _transacoes = [
    {
      'titulo': 'Aluguel - Apto 302',
      'tipo': 'entrada',
      'valor': 2500.00,
      'status': 'pago',
      'data': DateTime(2025, 11, 5)
    },
    {
      'titulo': 'Multa contratual - Inquilino 204',
      'tipo': 'entrada',
      'valor': 150.00,
      'status': 'pendente',
      'data': DateTime(2025, 11, 10)
    },
    {
      'titulo': 'Pagamento de funcionário',
      'tipo': 'saida',
      'valor': 3200.00,
      'status': 'atrasado',
      'data': DateTime(2025, 11, 2)
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final formato = NumberFormat.simpleCurrency(locale: 'pt_BR');

    // Lógica de filtro e ordenação (mantida)
    final transacoesFiltradas = _transacoes.where((t) {
      if (_filterTipoIndex == 1 && t['tipo'] != 'entrada') return false;
      if (_filterTipoIndex == 2 && t['tipo'] != 'saida') return false;
      if (_filterStatusIndex == 1 && t['status'] != 'pago') return false;
      if (_filterStatusIndex == 2 && t['status'] != 'pendente') return false;
      if (_filterStatusIndex == 3 && t['status'] != 'atrasado') return false;
      return true;
    }).toList()
      ..sort((a, b) => _ordenarPor == 'data'
          ? b['data'].compareTo(a['data'])
          : b['valor'].compareTo(a['valor']));

    // Lógica de cálculo (mantida)
    final totalEntradas = _transacoes
        .where((t) => t['tipo'] == 'entrada')
        .fold(0.0, (s, t) => s + t['valor']);
    final totalSaidas = _transacoes
        .where((t) => t['tipo'] == 'saida')
        .fold(0.0, (s, t) => s + t['valor']);
    final saldo = totalEntradas - totalSaidas;

    // 🚨 Conteúdo da página: Removido o Scaffold/AppBar
    return SafeArea(
      child: Column(
        children: [
          // 🔹 HEADER/APPBAR CUSTOMIZADA (Recriado para manter o visual)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fluxo de Pagamentos',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.doc_text_viewfinder),
                  onPressed: () => _gerarRelatorio(transacoesFiltradas),
                ),
              ],
            ),
          ),
          
          // 🔹 BODY
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // Resumo financeiro
                  _buildResumoFinanceiro(
                      isDark, formato, totalEntradas, totalSaidas, saldo),

                  const SizedBox(height: 20),

                  // Filtros combinados
                  _buildFiltros(),

                  const SizedBox(height: 16),

                  // Lista de Transações
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: transacoesFiltradas.isEmpty
                          ? const Center(
                              child: Text("Nenhuma transação encontrada."),
                            )
                          : ListView.builder(
                              key: ValueKey(transacoesFiltradas.length),
                              itemCount: transacoesFiltradas.length,
                              itemBuilder: (context, index) {
                                final t = transacoesFiltradas[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildCardTransacao(t, formato, isDark),
                                );
                              },
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Seus métodos auxiliares (mantidos)

  Widget _buildResumoFinanceiro(bool isDark, NumberFormat formato,
      double entradas, double saidas, double saldo) {
    // ... (o código deste método é o mesmo)
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _resumoItem(
                    'Entradas', formato.format(entradas), Colors.greenAccent),
                _resumoItem('Saídas', formato.format(saidas), Colors.redAccent),
                _resumoItem(
                  'Saldo',
                  formato.format(saldo),
                  saldo >= 0 ? Colors.greenAccent : Colors.redAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _resumoItem(String titulo, String valor, Color cor) {
    return Column(
      children: [
        Text(titulo, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 6),
        Text(valor,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: cor)),
      ],
    );
  }

  Widget _buildFiltros() {
    return Column(
      children: [
        CupertinoSegmentedControl<int>(
          children: const {
            0: Padding(padding: EdgeInsets.all(8), child: Text("Todos")),
            1: Padding(padding: EdgeInsets.all(8), child: Text("Entradas")),
            2: Padding(padding: EdgeInsets.all(8), child: Text("Saídas")),
          },
          groupValue: _filterTipoIndex,
          onValueChanged: (v) => setState(() => _filterTipoIndex = v),
        ),
        const SizedBox(height: 10),
        CupertinoSegmentedControl<int>(
          children: const {
            0: Padding(
                padding: EdgeInsets.all(8), child: Text("Status: Todos")),
            1: Padding(padding: EdgeInsets.all(8), child: Text("Pagos")),
            2: Padding(padding: EdgeInsets.all(8), child: Text("Pendentes")),
            3: Padding(padding: EdgeInsets.all(8), child: Text("Atrasados")),
          },
          groupValue: _filterStatusIndex,
          onValueChanged: (v) => setState(() => _filterStatusIndex = v),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text("Ordenar por: "),
            DropdownButton<String>(
              value: _ordenarPor,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'data', child: Text("Data")),
                DropdownMenuItem(value: 'valor', child: Text("Valor")),
              ],
              onChanged: (v) => setState(() => _ordenarPor = v!),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCardTransacao(
      Map<String, dynamic> t, NumberFormat formato, bool isDark) {
    // ... (o código deste método é o mesmo)
    final statusColor = {
      'pago': Colors.greenAccent,
      'pendente': Colors.orangeAccent,
      'atrasado': Colors.redAccent,
    }[t['status']]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            t['tipo'] == 'entrada'
                ? CupertinoIcons.arrow_down_circle_fill
                : CupertinoIcons.arrow_up_circle_fill,
            color:
                t['tipo'] == 'entrada' ? Colors.greenAccent : Colors.redAccent,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t['titulo'],
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(DateFormat('dd/MM/yyyy').format(t['data']),
                    style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formato.format(t['valor']),
                style: TextStyle(
                    color: t['tipo'] == 'entrada'
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  t['status'].toUpperCase(),
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ➕ BOTÃO ADICIONAR (Você não precisa disso aqui, pois o botão deve
  // estar no FloatingActionButton do Scaffold da HomePage, mas mantive a função
  // para você usá-la se quiser).
  void _adicionarTransacao() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text("Nova Transação"),
        actions: [
          CupertinoActionSheetAction(
            child: const Text("Adicionar Entrada"),
            onPressed: () {
              Navigator.pop(context);
              // Aqui abrir modal de formulário
            },
          ),
          CupertinoActionSheetAction(
            child: const Text("Adicionar Saída"),
            onPressed: () {
              Navigator.pop(context);
              // Aqui abrir modal de formulário
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.pop(context)),
      ),
    );
  }

  // Geração de PDF (mantida)
  void _gerarRelatorio(List<Map<String, dynamic>> transacoes) async {
    // ... (o código deste método é o mesmo)
    final pdf = pw.Document();

    final dataAtual = DateTime.now();
    final dataFormatada =
        "${dataAtual.day.toString().padLeft(2, '0')}-${dataAtual.month.toString().padLeft(2, '0')}-${dataAtual.year}";

    double entradas = 0;
    double saidas = 0;

    for (var t in transacoes) {
      if (t['tipo'] == 'entrada') {
        entradas += t['valor'];
      } else if (t['tipo'] == 'saida') {
        saidas += t['valor'];
      }
    }

    final saldo = entradas - saidas;

    // Montagem do PDF
    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              '📊 Relatório Financeiro - Aura Corretora Imobiliária',
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Text('Data de emissão: $dataFormatada',
              style: const pw.TextStyle(fontSize: 12)),

          pw.SizedBox(height: 20),

          pw.Table.fromTextArray(
            border: null,
            headers: ['Título', 'Tipo', 'Valor (R\$)', 'Status', 'Data'],
            data: transacoes.map((t) {
              return [
                t['titulo'],
                t['tipo'] == 'entrada' ? 'Entrada' : 'Saída',
                t['valor'].toStringAsFixed(2),
                t['status'].toUpperCase(),
                DateFormat('dd/MM/yyyy').format(t['data']), // Formatando a data
              ];
            }).toList(),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.black),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 11),
            rowDecoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
            ),
          ),

          pw.SizedBox(height: 30),

          pw.Divider(),

          // Resumo financeiro
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Entradas:',
                  style: pw.TextStyle(fontSize: 14, color: PdfColors.green)),
              pw.Text('R\$ ${entradas.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green)),
            ],
          ),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Saídas:',
                  style:
                      const pw.TextStyle(fontSize: 14, color: PdfColors.red)),
              pw.Text('R\$ ${saidas.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red)),
            ],
          ),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Saldo:',
                  style:
                      const pw.TextStyle(fontSize: 16, color: PdfColors.black)),
              pw.Text(
                'R\$ ${saldo.toStringAsFixed(2)}',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: saldo >= 0 ? PdfColors.green800 : PdfColors.red800,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    // Salvar o arquivo
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/relatorio_financeiro_$dataFormatada.pdf");
    await file.writeAsBytes(await pdf.save());

    // Abrir o arquivo automaticamente
    await OpenFilex.open(file.path);
  }
}