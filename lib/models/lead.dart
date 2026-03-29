class Lead {
  final String id;
  final String nome;
  final String? nicho;
  final String? cidade;
  final String? estado;
  final double? lat;
  final double? lng;
  final double fatEstimado;
  final String status;
  final String? pegoPor;
  final DateTime? pegoEm;
  final DateTime? expiraEm;
  final DateTime criadoEm;
  final bool isNovo;

  const Lead({
    required this.id,
    required this.nome,
    this.nicho,
    this.cidade,
    this.estado,
    this.lat,
    this.lng,
    required this.fatEstimado,
    required this.status,
    this.pegoPor,
    this.pegoEm,
    this.expiraEm,
    required this.criadoEm,
    required this.isNovo,
  });

  factory Lead.fromJson(Map<String, dynamic> j) => Lead(
    id:           j['id'] as String,
    nome:         j['nome'] as String,
    nicho:        j['nicho'] as String?,
    cidade:       j['cidade'] as String?,
    estado:       j['estado'] as String?,
    lat:          (j['lat'] as num?)?.toDouble(),
    lng:          (j['lng'] as num?)?.toDouble(),
    fatEstimado:  (j['fat_estimado'] as num? ?? 0).toDouble(),
    status:       j['status'] as String,
    pegoPor:      j['pego_por'] as String?,
    pegoEm:       j['pego_em'] != null ? DateTime.parse(j['pego_em'] as String) : null,
    expiraEm:     j['expira_em'] != null ? DateTime.parse(j['expira_em'] as String) : null,
    criadoEm:     DateTime.parse(j['criado_em'] as String),
    isNovo:       j['is_novo'] as bool? ?? false,
  );

  Duration? get tempoRestante => expiraEm?.difference(DateTime.now());
}
