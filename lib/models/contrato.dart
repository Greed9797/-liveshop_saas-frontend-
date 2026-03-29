class Contrato {
  final String id;
  final String clienteId;
  final String status;
  final double valorFixo;
  final double comissaoPct;
  final bool deRisco;
  final DateTime? assinadoEm;
  final DateTime? ativadoEm;

  const Contrato({
    required this.id,
    required this.clienteId,
    required this.status,
    required this.valorFixo,
    required this.comissaoPct,
    required this.deRisco,
    this.assinadoEm,
    this.ativadoEm,
  });

  factory Contrato.fromJson(Map<String, dynamic> j) => Contrato(
    id:           j['id'] as String,
    clienteId:    j['cliente_id'] as String,
    status:       j['status'] as String,
    valorFixo:    (j['valor_fixo'] as num).toDouble(),
    comissaoPct:  (j['comissao_pct'] as num).toDouble(),
    deRisco:      j['de_risco'] as bool? ?? false,
    assinadoEm:   j['assinado_em'] != null ? DateTime.parse(j['assinado_em'] as String) : null,
    ativadoEm:    j['ativado_em'] != null ? DateTime.parse(j['ativado_em'] as String) : null,
  );
}
