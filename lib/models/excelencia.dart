class ExcelenciaData {
  final int ativos;
  final int cancelados;
  final int taxaRetencao;
  final double fatMesAtual;
  final double fatMesAnterior;
  final int crescimentoPct;
  final int score;

  const ExcelenciaData({
    required this.ativos,
    required this.cancelados,
    required this.taxaRetencao,
    required this.fatMesAtual,
    required this.fatMesAnterior,
    required this.crescimentoPct,
    required this.score,
  });

  factory ExcelenciaData.fromJson(Map<String, dynamic> j) => ExcelenciaData(
    ativos:           (j['ativos'] as num).toInt(),
    cancelados:       (j['cancelados'] as num).toInt(),
    taxaRetencao:     (j['taxa_retencao'] as num).toInt(),
    fatMesAtual:      (j['fat_mes_atual'] as num).toDouble(),
    fatMesAnterior:   (j['fat_mes_anterior'] as num).toDouble(),
    crescimentoPct:   (j['crescimento_pct'] as num).toInt(),
    score:            (j['score'] as num).toInt(),
  );
}
