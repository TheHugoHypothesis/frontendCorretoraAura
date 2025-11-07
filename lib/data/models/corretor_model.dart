class CorretorModel {
  final String prenome;
  final String sobrenome;
  final String cpf;
  final String telefone;
  final String email;
  final String dataNascimento;
  final String creci;
  final String especialidade;
  final String regiaoAtuacao;
  // File? profileImage; // Adicione se for carregar a imagem do servidor

  const CorretorModel({
    required this.prenome,
    required this.sobrenome,
    required this.cpf,
    required this.telefone,
    required this.email,
    required this.dataNascimento,
    required this.creci,
    required this.especialidade,
    required this.regiaoAtuacao,
  });
}
