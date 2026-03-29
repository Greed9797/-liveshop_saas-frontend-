class Cliente {
  final String id;
  final String nome;
  final String celular;
  final String? email;
  final String status;
  final double? lat;
  final double? lng;
  final double fatAnual;
  final String? nicho;
  final int score;

  const Cliente({
    required this.id,
    required this.nome,
    required this.celular,
    this.email,
    required this.status,
    this.lat,
    this.lng,
    required this.fatAnual,
    this.nicho,
    required this.score,
  });

  factory Cliente.fromJson(Map<String, dynamic> j) => Cliente(
    id:       j['id'] as String,
    nome:     j['nome'] as String,
    celular:  j['celular'] as String,
    email:    j['email'] as String?,
    status:   j['status'] as String,
    lat:      (j['lat'] as num?)?.toDouble(),
    lng:      (j['lng'] as num?)?.toDouble(),
    fatAnual: (j['fat_anual'] as num? ?? 0).toDouble(),
    nicho:    j['nicho'] as String?,
    score:    (j['score'] as num? ?? 0).toInt(),
  );
}
