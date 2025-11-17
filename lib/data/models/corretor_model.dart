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

  factory CorretorModel.fromJson(Map<String, dynamic> json) {
    return CorretorModel(
      prenome: json['prenome'] ?? '',
      sobrenome: json['sobrenome'] ?? '',
      cpf: json['cpf'] ?? '',
      telefone: json['telefone'] ?? '',
      email: json['email'] ?? '',
      dataNascimento: json['dataNascimento'] ?? '',
      creci: json['creci'] ?? '',
      especialidade: json['especialidade'] ?? '',
      regiaoAtuacao: json['regiaoAtuacao'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'prenome': prenome,
      'sobrenome': sobrenome,
      'cpf': cpf,
      'telefone': telefone,
      'email': email,
      'dataNascimento': dataNascimento,
      'creci': creci,
      'especialidade': especialidade,
      'regiaoAtuacao': regiaoAtuacao,
    };
  }
}
