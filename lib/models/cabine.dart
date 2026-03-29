class Cabine {
  final String id;
  final int numero;
  final String status; // 'ao_vivo' | 'disponivel' | 'manutencao'
  final String? liveAtualId;
  final String? apresentadorNome;
  final String? clienteNome;
  final DateTime? iniciadoEm;

  const Cabine({
    required this.id,
    required this.numero,
    required this.status,
    this.liveAtualId,
    this.apresentadorNome,
    this.clienteNome,
    this.iniciadoEm,
  });

  factory Cabine.fromJson(Map<String, dynamic> j) => Cabine(
    id:               j['id'] as String,
    numero:           j['numero'] as int,
    status:           j['status'] as String,
    liveAtualId:      j['live_atual_id'] as String?,
    apresentadorNome: j['apresentador_nome'] as String?,
    clienteNome:      j['cliente_nome'] as String?,
    iniciadoEm:       j['iniciado_em'] != null ? DateTime.parse(j['iniciado_em'] as String) : null,
  );

  Map<String, dynamic> toCardMap() => {
    'numero':       numero,
    'status':       status,
    'apresentador': apresentadorNome,
    'cliente':      clienteNome,
    'horario':      iniciadoEm?.toLocal().toString().substring(11, 16),
    'tempo':        iniciadoEm != null
        ? _duracao(DateTime.now().difference(iniciadoEm!))
        : null,
  };

  static String _duracao(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '${h}h${m}m' : '${d.inMinutes}min';
  }
}
