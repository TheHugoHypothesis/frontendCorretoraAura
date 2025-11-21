import 'package:aura_frontend/data/models/contrato_model.dart';
import 'package:aura_frontend/data/models/imovel_model.dart';

final ImovelModel mockImovelPerformance = ImovelModel(
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
  contratos: [
    ContratoModel(
        codigo: 0,
        tipo: 'Aluguel',
        status: 'Finalizado',
        dataInicio: DateTime.parse('1969-07-20 20:18:04Z'),
        dataFim: DateTime.parse('1969-07-20 20:18:04Z'),
        cpfAdquirente: "b",
        cpfProprietario: "a",
        valor: 3500,
        matriculaImovel: 'Jumeirah Village'),
  ],
);

final List<String> mockStatusHistorico = [
  "2023-01-01: Alugado (R\$ 3.500,00)",
  "2022-12-15: Disponível",
  "2020-05-10: Vendido (R\$ 750.000,00)",
];
