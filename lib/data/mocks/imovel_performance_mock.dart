import 'package:aura_frontend/data/models/contrato_model.dart';
import 'package:aura_frontend/data/models/imovel_model.dart';

final ImovelModel mockImovelPerformance = ImovelModel(
  matricula: 'IMV98765',
  endereco:
      'Rua da Performance, 400 - Dubai', // Endereço mockado para o exemplo
  statusOcupacao: 'Disponível',
  valorVenal: 'R\$ 950.000,00',
  contratos: const [
    ContratoModel(
        id: '#0030A',
        tipo: 'Aluguel',
        status: 'Finalizado',
        dataInicio: '01/01/2023',
        valor: 'R\$ 3.500,00',
        imovel: 'Jumeirah Village'),
  ],
);

final List<String> mockStatusHistorico = [
  "2023-01-01: Alugado (R\$ 3.500,00)",
  "2022-12-15: Disponível",
  "2020-05-10: Vendido (R\$ 750.000,00)",
];
