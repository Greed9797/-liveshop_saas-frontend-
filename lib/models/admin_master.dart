double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _toInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String _toStringValue(dynamic value, [String fallback = '']) {
  final text = value?.toString();
  if (text == null || text.isEmpty) return fallback;
  return text;
}

List<Map<String, dynamic>> _toMapList(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

class MasterHistoryPoint {
  final String period;
  final String label;
  final double grossRevenue;
  final double franchisorRevenue;

  const MasterHistoryPoint({
    required this.period,
    required this.label,
    required this.grossRevenue,
    required this.franchisorRevenue,
  });

  factory MasterHistoryPoint.fromJson(Map<String, dynamic> json) {
    return MasterHistoryPoint(
      period: _toStringValue(json['period'] ?? json['periodo']),
      label: _toStringValue(json['label']),
      grossRevenue: _toDouble(
        json['gross_revenue'] ?? json['faturamento_bruto'],
      ),
      franchisorRevenue: _toDouble(
        json['franchisor_revenue'] ?? json['receita_franqueadora'],
      ),
    );
  }
}

class MasterPipelineStage {
  final String stage;
  final int count;
  final double value;

  const MasterPipelineStage({
    required this.stage,
    required this.count,
    required this.value,
  });

  factory MasterPipelineStage.fromJson(Map<String, dynamic> json) {
    return MasterPipelineStage(
      stage: _toStringValue(json['stage']),
      count: _toInt(json['count']),
      value: _toDouble(json['value']),
    );
  }
}

class MasterDashboardCards {
  final int unitsActive;
  final int clientsActive;
  final double grossRevenue;
  final double franchisorNetRevenue;
  final int pendingContracts;
  final double growthPercent;
  final double delinquencyValue;
  final double delinquencyPercent;
  final double averageTicketPerUnit;

  const MasterDashboardCards({
    required this.unitsActive,
    required this.clientsActive,
    required this.grossRevenue,
    required this.franchisorNetRevenue,
    required this.pendingContracts,
    required this.growthPercent,
    required this.delinquencyValue,
    required this.delinquencyPercent,
    required this.averageTicketPerUnit,
  });

  factory MasterDashboardCards.fromJson(Map<String, dynamic> json) {
    return MasterDashboardCards(
      unitsActive: _toInt(json['unidades_ativas']),
      clientsActive: _toInt(json['clientes_ativos']),
      grossRevenue: _toDouble(json['faturamento_bruto_rede']),
      franchisorNetRevenue: _toDouble(json['receita_liquida_franqueadora']),
      pendingContracts: _toInt(json['contratos_pendentes']),
      growthPercent: _toDouble(json['crescimento_percentual']),
      delinquencyValue: _toDouble(json['inadimplencia_valor']),
      delinquencyPercent: _toDouble(json['inadimplencia_percentual']),
      averageTicketPerUnit: _toDouble(json['ticket_medio_unidade']),
    );
  }
}

class MasterRankingItem {
  final String unitId;
  final String unitName;
  final double grossRevenue;
  final double growthPercent;

  const MasterRankingItem({
    required this.unitId,
    required this.unitName,
    required this.grossRevenue,
    required this.growthPercent,
  });

  factory MasterRankingItem.fromJson(Map<String, dynamic> json) {
    return MasterRankingItem(
      unitId: _toStringValue(json['unit_id']),
      unitName: _toStringValue(json['unit_name']),
      grossRevenue: _toDouble(json['gross_revenue']),
      growthPercent: _toDouble(json['growth_pct']),
    );
  }
}

class MasterAlertItem {
  final String type;
  final String severity;
  final String unitId;
  final String unitName;
  final String title;
  final String description;

  const MasterAlertItem({
    required this.type,
    required this.severity,
    required this.unitId,
    required this.unitName,
    required this.title,
    required this.description,
  });

  factory MasterAlertItem.fromJson(Map<String, dynamic> json) {
    return MasterAlertItem(
      type: _toStringValue(json['type']),
      severity: _toStringValue(json['severity'], 'media'),
      unitId: _toStringValue(json['unit_id']),
      unitName: _toStringValue(json['unit_name']),
      title: _toStringValue(json['title']),
      description: _toStringValue(json['description']),
    );
  }
}

class MasterGrowthUnit {
  final String unitId;
  final String unitName;
  final double growthPercent;
  final double grossRevenue;
  final double previousGrossRevenue;

  const MasterGrowthUnit({
    required this.unitId,
    required this.unitName,
    required this.growthPercent,
    required this.grossRevenue,
    required this.previousGrossRevenue,
  });

  factory MasterGrowthUnit.fromJson(Map<String, dynamic> json) {
    return MasterGrowthUnit(
      unitId: _toStringValue(json['unit_id']),
      unitName: _toStringValue(json['unit_name']),
      growthPercent: _toDouble(json['growth_pct']),
      grossRevenue: _toDouble(json['gross_revenue']),
      previousGrossRevenue: _toDouble(json['previous_gross_revenue']),
    );
  }
}

class MasterCommissionSummary {
  final double forecast;
  final double received;
  final double pending;
  final double overdue;

  const MasterCommissionSummary({
    required this.forecast,
    required this.received,
    required this.pending,
    required this.overdue,
  });

  factory MasterCommissionSummary.fromJson(Map<String, dynamic> json) {
    return MasterCommissionSummary(
      forecast: _toDouble(json['previsto']),
      received: _toDouble(json['recebido']),
      pending: _toDouble(json['pendente']),
      overdue: _toDouble(json['inadimplente']),
    );
  }
}

class MasterDashboardData {
  final String period;
  final String previousPeriod;
  final MasterDashboardCards cards;
  final String executiveSummary;
  final List<MasterRankingItem> revenueRanking;
  final List<MasterRankingItem> growthRanking;
  final List<MasterAlertItem> alerts;
  final List<MasterHistoryPoint> networkHistory;
  final List<MasterGrowthUnit> unitGrowth;
  final List<MasterPipelineStage> crmPipeline;
  final MasterCommissionSummary commissionSummary;

  const MasterDashboardData({
    required this.period,
    required this.previousPeriod,
    required this.cards,
    required this.executiveSummary,
    required this.revenueRanking,
    required this.growthRanking,
    required this.alerts,
    required this.networkHistory,
    required this.unitGrowth,
    required this.crmPipeline,
    required this.commissionSummary,
  });

  factory MasterDashboardData.fromJson(Map<String, dynamic> json) {
    final rankings = Map<String, dynamic>.from(
      (json['rankings'] as Map?) ?? const {},
    );

    return MasterDashboardData(
      period: _toStringValue(json['periodo']),
      previousPeriod: _toStringValue(json['periodo_anterior']),
      cards: MasterDashboardCards.fromJson(
        Map<String, dynamic>.from((json['cards'] as Map?) ?? const {}),
      ),
      executiveSummary: _toStringValue(json['resumo_executivo']),
      revenueRanking: _toMapList(
        rankings['faturamento'],
      ).map(MasterRankingItem.fromJson).toList(),
      growthRanking: _toMapList(
        rankings['crescimento'],
      ).map(MasterRankingItem.fromJson).toList(),
      alerts: _toMapList(
        json['alertas'],
      ).map(MasterAlertItem.fromJson).toList(),
      networkHistory: _toMapList(
        json['historico_rede'],
      ).map(MasterHistoryPoint.fromJson).toList(),
      unitGrowth: _toMapList(
        json['crescimento_unidades'],
      ).map(MasterGrowthUnit.fromJson).toList(),
      crmPipeline: _toMapList(
        json['crm_pipeline'],
      ).map(MasterPipelineStage.fromJson).toList(),
      commissionSummary: MasterCommissionSummary.fromJson(
        Map<String, dynamic>.from(
          (json['comissionamento'] as Map?) ?? const {},
        ),
      ),
    );
  }
}

class MasterUnitsSummary {
  final int totalUnits;
  final int activeClients;
  final double grossRevenue;
  final double franchisorRevenue;

  const MasterUnitsSummary({
    required this.totalUnits,
    required this.activeClients,
    required this.grossRevenue,
    required this.franchisorRevenue,
  });

  factory MasterUnitsSummary.fromJson(Map<String, dynamic> json) {
    return MasterUnitsSummary(
      totalUnits: _toInt(json['total_unidades']),
      activeClients: _toInt(json['clientes_ativos']),
      grossRevenue: _toDouble(json['faturamento_bruto']),
      franchisorRevenue: _toDouble(json['receita_franqueadora']),
    );
  }
}

class MasterClient {
  final String id;
  final String name;
  final String status;
  final double grossRevenue;
  final double contractPercent;
  final double franchisorRevenue;
  final double monthlyFee;
  final double liveGmv;
  final String notes;

  const MasterClient({
    required this.id,
    required this.name,
    required this.status,
    required this.grossRevenue,
    required this.contractPercent,
    required this.franchisorRevenue,
    required this.monthlyFee,
    required this.liveGmv,
    required this.notes,
  });

  factory MasterClient.fromJson(Map<String, dynamic> json) {
    return MasterClient(
      id: _toStringValue(json['id']),
      name: _toStringValue(json['name']),
      status: _toStringValue(json['status'], 'negociacao'),
      grossRevenue: _toDouble(json['gross_revenue']),
      contractPercent: _toDouble(json['contract_pct']),
      franchisorRevenue: _toDouble(json['franchisor_revenue']),
      monthlyFee: _toDouble(json['monthly_fee']),
      liveGmv: _toDouble(json['live_gmv']),
      notes: _toStringValue(json['notes']),
    );
  }
}

class MasterUnit {
  final String id;
  final String name;
  final String status;
  final String? region;
  final int activeClients;
  final double grossRevenue;
  final double unitNetRevenue;
  final double franchisorRevenue;
  final double growthPercent;
  final double contractPercent;
  final int pendingContracts;
  final double takeRate;
  final List<MasterHistoryPoint> history;
  final List<MasterClient> clients;

  const MasterUnit({
    required this.id,
    required this.name,
    required this.status,
    this.region,
    required this.activeClients,
    required this.grossRevenue,
    required this.unitNetRevenue,
    required this.franchisorRevenue,
    required this.growthPercent,
    required this.contractPercent,
    required this.pendingContracts,
    required this.takeRate,
    required this.history,
    required this.clients,
  });

  factory MasterUnit.fromJson(Map<String, dynamic> json) {
    return MasterUnit(
      id: _toStringValue(json['id']),
      name: _toStringValue(json['name']),
      status: _toStringValue(json['status'], 'ativo'),
      region: json['region']?.toString(),
      activeClients: _toInt(json['active_clients']),
      grossRevenue: _toDouble(json['gross_revenue']),
      unitNetRevenue: _toDouble(json['unit_net_revenue']),
      franchisorRevenue: _toDouble(json['franchisor_revenue']),
      growthPercent: _toDouble(json['growth_pct']),
      contractPercent: _toDouble(json['contract_pct']),
      pendingContracts: _toInt(json['pending_contracts']),
      takeRate: _toDouble(json['take_rate']),
      history: _toMapList(
        json['history'],
      ).map(MasterHistoryPoint.fromJson).toList(),
      clients: _toMapList(json['clients']).map(MasterClient.fromJson).toList(),
    );
  }
}

class MasterUnitsData {
  final String period;
  final String status;
  final MasterUnitsSummary summary;
  final List<MasterUnit> units;

  const MasterUnitsData({
    required this.period,
    required this.status,
    required this.summary,
    required this.units,
  });

  factory MasterUnitsData.fromJson(Map<String, dynamic> json) {
    return MasterUnitsData(
      period: _toStringValue(json['periodo']),
      status: _toStringValue(json['status'], 'todos'),
      summary: MasterUnitsSummary.fromJson(
        Map<String, dynamic>.from((json['summary'] as Map?) ?? const {}),
      ),
      units: _toMapList(json['units']).map(MasterUnit.fromJson).toList(),
    );
  }
}

class MasterConsolidatedOverview {
  final double grossRevenue;
  final double franchisorRevenue;
  final double monthlyFeeRevenue;
  final double commissionRevenue;
  final double otherRevenue;
  final double growthPercent;
  final double mrrNetwork;
  final double averageTakeRate;
  final double receivableForecast;
  final double delinquencyValue;
  final double delinquencyPercent;
  final double comparisonValue;

  const MasterConsolidatedOverview({
    required this.grossRevenue,
    required this.franchisorRevenue,
    required this.monthlyFeeRevenue,
    required this.commissionRevenue,
    required this.otherRevenue,
    required this.growthPercent,
    required this.mrrNetwork,
    required this.averageTakeRate,
    required this.receivableForecast,
    required this.delinquencyValue,
    required this.delinquencyPercent,
    required this.comparisonValue,
  });

  factory MasterConsolidatedOverview.fromJson(Map<String, dynamic> json) {
    return MasterConsolidatedOverview(
      grossRevenue: _toDouble(json['faturamento_bruto_rede']),
      franchisorRevenue: _toDouble(json['receita_franqueadora']),
      monthlyFeeRevenue: _toDouble(json['receita_mensalidade']),
      commissionRevenue: _toDouble(json['receita_comissao']),
      otherRevenue: _toDouble(json['receita_outros']),
      growthPercent: _toDouble(json['crescimento_percentual']),
      mrrNetwork: _toDouble(json['mrr_rede']),
      averageTakeRate: _toDouble(json['take_rate_medio']),
      receivableForecast: _toDouble(json['previsao_recebimento']),
      delinquencyValue: _toDouble(json['inadimplencia_valor']),
      delinquencyPercent: _toDouble(json['inadimplencia_percentual']),
      comparisonValue: _toDouble(json['comparativo_valor']),
    );
  }
}

class MasterConsolidatedUnit {
  final String id;
  final String name;
  final String status;
  final double grossRevenue;
  final double contractPercent;
  final double franchisorRevenue;
  final double growthPercent;
  final double takeRate;

  const MasterConsolidatedUnit({
    required this.id,
    required this.name,
    required this.status,
    required this.grossRevenue,
    required this.contractPercent,
    required this.franchisorRevenue,
    required this.growthPercent,
    required this.takeRate,
  });

  factory MasterConsolidatedUnit.fromJson(Map<String, dynamic> json) {
    return MasterConsolidatedUnit(
      id: _toStringValue(json['id']),
      name: _toStringValue(json['name']),
      status: _toStringValue(json['status'], 'ativo'),
      grossRevenue: _toDouble(json['gross_revenue']),
      contractPercent: _toDouble(json['contract_pct']),
      franchisorRevenue: _toDouble(json['franchisor_revenue']),
      growthPercent: _toDouble(json['growth_pct']),
      takeRate: _toDouble(json['take_rate']),
    );
  }
}

class MasterConsolidatedData {
  final String period;
  final String status;
  final MasterConsolidatedOverview overview;
  final List<MasterHistoryPoint> history;
  final List<MasterConsolidatedUnit> units;

  const MasterConsolidatedData({
    required this.period,
    required this.status,
    required this.overview,
    required this.history,
    required this.units,
  });

  factory MasterConsolidatedData.fromJson(Map<String, dynamic> json) {
    return MasterConsolidatedData(
      period: _toStringValue(json['periodo']),
      status: _toStringValue(json['status'], 'todos'),
      overview: MasterConsolidatedOverview.fromJson(
        Map<String, dynamic>.from((json['overview'] as Map?) ?? const {}),
      ),
      history: _toMapList(
        json['historico'],
      ).map(MasterHistoryPoint.fromJson).toList(),
      units: _toMapList(
        json['units'],
      ).map(MasterConsolidatedUnit.fromJson).toList(),
    );
  }
}

class MasterCrmSummary {
  final int totalLeads;
  final double estimatedValue;
  final int leadPool;
  final int engagedLeads;
  final int expiredLeads;
  final int pendingContracts;

  const MasterCrmSummary({
    required this.totalLeads,
    required this.estimatedValue,
    required this.leadPool,
    required this.engagedLeads,
    required this.expiredLeads,
    required this.pendingContracts,
  });

  factory MasterCrmSummary.fromJson(Map<String, dynamic> json) {
    return MasterCrmSummary(
      totalLeads: _toInt(json['total_leads']),
      estimatedValue: _toDouble(json['estimated_value']),
      leadPool: _toInt(json['lead_pool']),
      engagedLeads: _toInt(json['engaged_leads']),
      expiredLeads: _toInt(json['expired_leads']),
      pendingContracts: _toInt(json['contratos_pendentes']),
    );
  }
}

class MasterCrmData {
  final bool isPlaceholder;
  final MasterCrmSummary summary;
  final List<MasterPipelineStage> pipeline;
  final List<String> recommendedFields;
  final String message;

  const MasterCrmData({
    required this.isPlaceholder,
    required this.summary,
    required this.pipeline,
    required this.recommendedFields,
    required this.message,
  });

  factory MasterCrmData.fromJson(Map<String, dynamic> json) {
    final fields = (json['recommended_fields'] as List? ?? const [])
        .map((item) => item.toString())
        .toList();

    return MasterCrmData(
      isPlaceholder: json['is_placeholder'] == true,
      summary: MasterCrmSummary.fromJson(
        Map<String, dynamic>.from((json['summary'] as Map?) ?? const {}),
      ),
      pipeline: _toMapList(
        json['pipeline'],
      ).map(MasterPipelineStage.fromJson).toList(),
      recommendedFields: fields,
      message: _toStringValue(json['message']),
    );
  }
}
