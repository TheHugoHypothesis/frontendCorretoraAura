import 'package:aura_frontend/data/models/contrato_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ImovelModel {
  // 1. Identificadores e Descrição
  final String matricula;
  final String descricao;
  final String cpfProprietario; // cpf_prop

  // 2. Endereço (Campos Brutos)
  final String logradouro;
  final String numero;
  final String complemento;
  final String bairro;
  final String cidade;
  final String cep;

  // 3. Características Físicas
  final double metragem;
  final int numQuartos; // n_quartos
  final int numReformas; // n_reformas
  final String tipo;
  final String finalidade;
  final bool possuiGaragem;
  final bool eMobiliado; // mobiliado

  // 4. Valores e Status
  final double valorVenalRaw; // Valor numérico puro (380000.0)
  final String
      statusOcupacao; // Backend não mandou no JSON de exemplo, usaremos default

  // 5. Listas e Mídia
  final List<String> imagens; // Lista de URLs
  final List<String> comodidades;
  final List<ContratoModel> contratos;

  const ImovelModel({
    required this.matricula,
    required this.descricao,
    required this.cpfProprietario,
    required this.logradouro,
    required this.numero,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.cep,
    required this.metragem,
    required this.numQuartos,
    required this.numReformas,
    required this.tipo,
    required this.finalidade,
    required this.possuiGaragem,
    required this.eMobiliado,
    required this.valorVenalRaw,
    this.statusOcupacao = 'Disponível', // Default
    this.imagens = const [],
    this.comodidades = const [],
    this.contratos = const [],
  });

  // --- GETTERS INTELIGENTES (Para a UI) ---

  // Retorna o endereço completo formatado para o Card
  String get enderecoCompleto =>
      "$logradouro, $numero${complemento.isNotEmpty ? ' - $complemento' : ''} - $bairro, $cidade";

  // Retorna a primeira imagem ou null (para o PropertyCard)
  String? get profileImageUrl => imagens.isNotEmpty ? imagens.first : null;

  // Retorna o valor formatado em R$ (para a UI)
  String get valorVenalFormatado {
    final format = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return format.format(valorVenalRaw);
  }

  // --- FACTORY (Mapeamento do Backend) ---

  factory ImovelModel.fromJson(Map<String, dynamic> json) {
    // Tratamento da lista de imagens (que pode vir com null dentro: [null])
    List<String> listaImagens = [];
    if (json['imagens'] != null && json['imagens'] is List) {
      listaImagens = (json['imagens'] as List)
          .where((item) => item != null) // Filtra nulos
          .map((item) => item.toString())
          .toList();
    }

    // Tratamento de Contratos (se vierem)
    List<ContratoModel> listaContratos = [];
    if (json['contratos'] != null && json['contratos'] is List) {
      listaContratos = (json['contratos'] as List)
          .map((c) => ContratoModel.fromJson(c))
          .toList();
    }

    // Tratamento de Comodidades (se vierem)
    // Nota: O JSON de exemplo não mostrou 'comodidades', mas se vier:
    List<String> listaComodidades = [];
    if (json['comodidades'] != null) {
      if (json['comodidades'] is List) {
        listaComodidades =
            (json['comodidades'] as List).map((e) => e.toString()).toList();
      } else if (json['comodidades'] is String) {
        // Se vier string separada por vírgula
        listaComodidades = (json['comodidades'] as String).split(',');
      }
    }

    return ImovelModel(
      matricula: json['matricula']?.toString() ?? '',
      descricao: json['descricao'] ?? '',
      cpfProprietario: json['cpf_prop'] ?? '',

      logradouro: json['logradouro'] ?? '',
      numero: json['numero'] ?? '',
      complemento: json['complemento'] ?? '',
      bairro: json['bairro'] ?? '',
      cidade: json['cidade'] ?? '',
      cep: json['cep'] ?? '',

      metragem: (json['metragem'] as num?)?.toDouble() ?? 0.0,
      numQuartos: json['n_quartos'] as int? ?? 0,
      numReformas: json['n_reformas'] as int? ?? 0,

      tipo: json['tipo'] ?? '',
      finalidade: json['finalidade'] ?? '',

      possuiGaragem: json['possui_garagem'] ?? false,
      eMobiliado: json['mobiliado'] ?? false, // Backend usa 'mobiliado'

      valorVenalRaw: (json['valor_venal'] as num?)?.toDouble() ?? 0.0,

      // O Backend não mandou status no JSON de exemplo, mantemos o default ou tentamos ler
      statusOcupacao: json['status'] ?? 'Disponível',

      imagens: listaImagens,
      contratos: listaContratos,
      comodidades: listaComodidades,
    );
  }

  // Para envio (se necessário)
  Map<String, dynamic> toJson() {
    return {
      'matricula': matricula,
      'cpf_prop': cpfProprietario,
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'cep': cep,
      'metragem': metragem,
      'n_quartos': numQuartos,
      'n_reformas': numReformas,
      'tipo': tipo,
      'finalidade': finalidade,
      'possui_garagem': possuiGaragem,
      'mobiliado': eMobiliado,
      'valor_venal': valorVenalRaw,
      'descricao': descricao,
    };
  }
}
