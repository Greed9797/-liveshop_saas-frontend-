class Pacote {
  final String id;
  final String nome;
  final String? descricao;
  final double valor;
  final double horasIncluidas;
  final double comissaoPct;
  final bool ativo;

  const Pacote({
    required this.id,
    required this.nome,
    this.descricao,
    required this.valor,
    required this.horasIncluidas,
    this.comissaoPct = 0,
    required this.ativo,
  });

  factory Pacote.fromJson(Map<String, dynamic> j) => Pacote(
        id: j['id'] as String,
        nome: j['nome'] as String,
        descricao: j['descricao'] as String?,
        valor: (j['valor'] as num? ?? 0).toDouble(),
        horasIncluidas: (j['horas_incluidas'] as num? ?? 0).toDouble(),
        comissaoPct: (j['comissao_pct'] as num? ?? 0).toDouble(),
        ativo: j['ativo'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'nome': nome,
        if (descricao != null) 'descricao': descricao,
        'valor': valor,
        'horas_incluidas': horasIncluidas,
        'ativo': ativo,
      };
}
