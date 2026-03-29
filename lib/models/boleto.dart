class Boleto {
  final String id;
  final String tipo;
  final double valor;
  final DateTime vencimento;
  final String status;
  final DateTime? pagoEm;
  final String? referenciaExterna;

  const Boleto({
    required this.id,
    required this.tipo,
    required this.valor,
    required this.vencimento,
    required this.status,
    this.pagoEm,
    this.referenciaExterna,
  });

  factory Boleto.fromJson(Map<String, dynamic> j) => Boleto(
    id:                  j['id'] as String,
    tipo:                j['tipo'] as String,
    valor:               (j['valor'] as num).toDouble(),
    vencimento:          DateTime.parse(j['vencimento'] as String),
    status:              j['status'] as String,
    pagoEm:              j['pago_em'] != null ? DateTime.parse(j['pago_em'] as String) : null,
    referenciaExterna:   j['referencia_externa'] as String?,
  );
}
