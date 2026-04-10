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
  // Novos campos (Módulo 1 + 2)
  final String? cep;
  final String? cidade;
  final String? estado;
  final String? siga;

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
    this.cep,
    this.cidade,
    this.estado,
    this.siga,
  });

  factory Cliente.fromJson(Map<String, dynamic> j) => Cliente(
    id:       j['id'] as String,
    nome:     j['nome'] as String,
    celular:  j['celular'] as String,
    email:    j['email'] as String?,
    status:   j['status'] as String,
    lat:      j['lat'] == null ? null : double.tryParse(j['lat'].toString()),
    lng:      j['lng'] == null ? null : double.tryParse(j['lng'].toString()),
    fatAnual: j['fat_anual'] == null ? 0.0 : double.tryParse(j['fat_anual'].toString()) ?? 0.0,
    nicho:    j['nicho'] as String?,
    score:    j['score'] == null ? 0 : int.tryParse(j['score'].toString()) ?? 0,
    cep:      j['cep'] as String?,
    cidade:   j['cidade'] as String?,
    estado:   j['estado'] as String?,
    siga:     j['siga'] as String?,
  );
}
