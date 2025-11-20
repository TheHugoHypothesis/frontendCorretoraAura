import 'package:aura_frontend/data/models/contrato_model.dart';
import 'package:flutter/material.dart';

class ImovelModel {
  final String matricula;
  final String endereco;
  final String statusOcupacao;
  final String valorVenal;
  final String? profileImageUrl; // Novo: URL da imagem principal

  final double? metragem;
  final int? numQuartos;
  final int? numReformas;
  final String? tipo; // Apartamento, Casa, etc.
  final String? finalidade; // Residencial/Comercial

  final bool possuiGaragem;
  final bool eMobiliado;

  final List<String> comodidades;

  final List<ContratoModel> contratos;

  const ImovelModel({
    required this.matricula,
    required this.endereco,
    required this.statusOcupacao,
    required this.valorVenal,
    required this.contratos,
    this.profileImageUrl,
    this.metragem,
    this.numQuartos,
    this.numReformas,
    this.tipo,
    this.finalidade,
    this.possuiGaragem = false,
    this.eMobiliado = false,
    this.comodidades = const [],
  });

  factory ImovelModel.fromJson(Map<String, dynamic> json) {
    final contratosList = (json['contratos'] as List<dynamic>?)
            ?.map((c) => ContratoModel.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [];

    final comodidadesList = (json['comodidades'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return ImovelModel(
      matricula: json['matricula'] ?? '',
      endereco: json['endereco'] ?? '',
      statusOcupacao: json['statusOcupacao'] ?? 'Disponível',
      valorVenal: json['valorVenal'] ?? 'R\$ 0,00',
      profileImageUrl: json['profileImageUrl'],
      metragem: (json['metragem'] as num?)?.toDouble(),
      numQuartos: json['numQuartos'] as int?,
      numReformas: json['numReformas'] as int?,
      tipo: json['tipo'] as String?,
      finalidade: json['finalidade'] as String?,
      possuiGaragem: json['possuiGaragem'] ?? false,
      eMobiliado: json['eMobiliado'] ?? false,
      comodidades: comodidadesList,
      contratos: contratosList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matricula': matricula,
      'endereco': endereco,
      'statusOcupacao': statusOcupacao,
      'valorVenal': valorVenal,
      'profileImageUrl': profileImageUrl,
      'metragem': metragem,
      'numQuartos': numQuartos,
      'numReformas': numReformas,
      'tipo': tipo,
      'finalidade': finalidade,
      'possuiGaragem': possuiGaragem,
      'eMobiliado': eMobiliado,
      'comodidades': comodidades,
    };
  }
}
