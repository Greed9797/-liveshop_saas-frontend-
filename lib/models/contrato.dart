class Contrato {
  final String id;
  final String clienteId;
  final String status;
  final double valorFixo;
  final double comissaoPct;
  final bool deRisco;
  final bool isRiscoFranqueado;
  final DateTime? assinadoEm;
  final DateTime? ativadoEm;
  final String? signatureImageUrl;
  final String? signedIp;
  final DateTime? acceptedTermsAt;
  // Para a tela de Análise de Crédito (campos do JOIN com clientes)
  final String? clienteNome;
  final String? clienteCnpj;
  final double? clienteFatAnual;
  final String? clienteNicho;
  final int? clienteScore;

  const Contrato({
    required this.id,
    required this.clienteId,
    required this.status,
    required this.valorFixo,
    required this.comissaoPct,
    required this.deRisco,
    this.isRiscoFranqueado = false,
    this.assinadoEm,
    this.ativadoEm,
    this.signatureImageUrl,
    this.signedIp,
    this.acceptedTermsAt,
    this.clienteNome,
    this.clienteCnpj,
    this.clienteFatAnual,
    this.clienteNicho,
    this.clienteScore,
  });

  factory Contrato.fromJson(Map<String, dynamic> j) => Contrato(
    id:                  j['id'] as String,
    clienteId:           j['cliente_id'] as String? ?? '',
    status:              j['status'] as String,
    valorFixo:           (j['valor_fixo'] as num? ?? 0).toDouble(),
    comissaoPct:         (j['comissao_pct'] as num? ?? 0).toDouble(),
    deRisco:             j['de_risco'] as bool? ?? false,
    isRiscoFranqueado:   j['is_risco_franqueado'] as bool? ?? false,
    assinadoEm:          j['assinado_em'] != null ? DateTime.parse(j['assinado_em'] as String) : null,
    ativadoEm:           j['ativado_em'] != null ? DateTime.parse(j['ativado_em'] as String) : null,
    signatureImageUrl:   j['signature_image_url'] as String?,
    signedIp:            j['signed_ip'] as String?,
    acceptedTermsAt:     j['accepted_terms_at'] != null ? DateTime.parse(j['accepted_terms_at'] as String) : null,
    clienteNome:         j['nome'] as String?,
    clienteCnpj:         j['cnpj'] as String?,
    clienteFatAnual:     (j['fat_anual'] as num?)?.toDouble(),
    clienteNicho:        j['nicho'] as String?,
    clienteScore:        (j['score'] as num?)?.toInt(),
  );
}
