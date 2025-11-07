class TransacaoModel {
  final String titulo;
  final String tipo; // 'entrada' ou 'saida'
  final double valor;
  final String status; // 'pago', 'pendente', 'atrasado'
  final DateTime data;

  const TransacaoModel({
    required this.titulo,
    required this.tipo,
    required this.valor,
    required this.status,
    required this.data,
  });

  // Método de conveniência para converter Map (do mock) para o Model
  factory TransacaoModel.fromMap(Map<String, dynamic> map) {
    return TransacaoModel(
      titulo: map['titulo'] as String,
      tipo: map['tipo'] as String,
      valor: map['valor'] as double,
      status: map['status'] as String,
      data: map['data'] as DateTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'tipo': tipo,
      'valor': valor,
      'status': status,
      'data': data,
    };
  }
}
