import 'package:flutter/material.dart';

import '../models/contrato_model.dart';
import '../models/imovel_model.dart';
import '../models/proprietario_model.dart';

final ContratoModel mockContratoAtivo = ContratoModel(
    codigo: 0,
    tipo: 'Aluguel',
    status: 'Vigente',
    dataInicio: DateTime.now(),
    dataFim: DateTime.now(),
    cpfAdquirente: "",
    cpfProprietario: "",
    valor: 3500,
    matriculaImovel: 'Apto. Alameda Santos');

final ImovelModel mockImovel1 = ImovelModel(
    matricula: 'IMV98765',
    descricao: "",
    cpfProprietario: "",
    logradouro: "",
    numero: "",
    complemento: "",
    bairro: "",
    cidade: "",
    cep: "",
    metragem: 150.3,
    numQuartos: 3,
    numReformas: 2,
    tipo: "",
    finalidade: "",
    possuiGaragem: true,
    eMobiliado: false,
    statusOcupacao: 'Disponível',
    valorVenalRaw: 950000,
    contratos: []);

final ImovelModel mockImovel2 = ImovelModel(
    matricula: 'IMV98765',
    descricao: "",
    cpfProprietario: "",
    logradouro: "",
    numero: "",
    complemento: "",
    bairro: "",
    cidade: "",
    cep: "",
    metragem: 150.3,
    numQuartos: 3,
    numReformas: 2,
    tipo: "",
    finalidade: "",
    possuiGaragem: true,
    eMobiliado: false,
    statusOcupacao: 'Disponível',
    valorVenalRaw: 950000,
    contratos: []);

final ProprietarioModel mockProprietarioPrincipal = ProprietarioModel(
    nome: 'Carlos',
    sobrenome: 'Ferreira',
    cpf: '999.888.777-66',
    telefone: '(11) 97777-6666',
    email: 'carlos.ferreira@prop.com',
    dataNascimento: '20/03/1975',
    imoveis: [mockImovel1, mockImovel2]);

// Lista Completa de Proprietários para a Listagem
final List<ProprietarioModel> mockProprietariosList = [
  mockProprietarioPrincipal,
  const ProprietarioModel(
    nome: 'Alice',
    sobrenome: 'Dias',
    cpf: '111.000.222-33',
    telefone: '(11) 96666-5555',
    email: 'alice.dias@prop.com',
    dataNascimento: '10/12/1990',
    imoveis: [],
  ),
];
