import 'package:flutter/material.dart';

import '../models/contrato_model.dart';
import '../models/imovel_model.dart';
import '../models/proprietario_model.dart';

final ContratoModel mockContratoAtivo = ContratoModel(
    id: '#0025A',
    tipo: 'Aluguel',
    status: 'Vigente',
    dataInicio: '01/01/2024',
    valor: 'R\$ 3.500,00',
    imovel: 'Apto. Alameda Santos');

final ImovelModel mockImovel1 = ImovelModel(
    matricula: '123456',
    endereco: 'Av. Ibirapuera, 1000',
    statusOcupacao: 'Alugado',
    valorVenal: 'R\$ 600.000,00',
    contratos: [mockContratoAtivo]);

final ImovelModel mockImovel2 = ImovelModel(
    matricula: '789012',
    endereco: 'Rua Bela Cintra, 50',
    statusOcupacao: 'Vendido',
    valorVenal: 'R\$ 1.200.000,00',
    contratos: const []);

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
