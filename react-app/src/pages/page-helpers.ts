import type { ChartPoint, JsonRecord, Metric } from '../types/models'
import { asArray, asNumber, asString, formatMoney, formatPercent, getRecord } from '../utils/format'

export function metric(label: string, value: unknown, hint?: string, tone: Metric['tone'] = 'neutral'): Metric {
  return { label, value: String(value ?? '—'), hint, tone }
}

export function moneyMetric(label: string, value: unknown, hint?: string, tone: Metric['tone'] = 'brand'): Metric {
  return metric(label, formatMoney(value), hint, tone)
}

export function percentMetric(label: string, value: unknown, hint?: string, tone: Metric['tone'] = 'info'): Metric {
  return metric(label, formatPercent(value), hint, tone)
}

export function historyPoints(raw: unknown, labelKeys = ['label', 'mes', 'periodo', 'data'], valueKeys = ['gmv', 'valor', 'total', 'receita']): ChartPoint[] {
  return asArray<JsonRecord>(raw).map((item, index) => {
    const labelValue = labelKeys.map((key) => item[key]).find((value) => value !== undefined)
    const value = valueKeys.map((key) => item[key]).find((candidate) => candidate !== undefined)
    return {
      label: asString(labelValue, `${index + 1}`),
      value: asNumber(value),
      secondary: asNumber(item.lives ?? item.qtd_lives ?? item.total_lives),
    }
  })
}

export function normalizeHome(raw: JsonRecord) {
  const resumo = raw.resumo_mes ? getRecord(raw.resumo_mes) : raw
  const cabines = asArray<JsonRecord>(raw.cabines)
  const liveCabines = cabines.filter((cabine) => asString(cabine.status, '').includes('ao_vivo'))
  const ocupacao = getRecord(raw.ocupacao_cabines_hoje)
  const alertas = getRecord(raw.alertas)

  return {
    metrics: [
      moneyMetric('GMV do mês', raw.gmv_lives_mes ?? raw.gmv_mes ?? resumo.gmv_lives_mes ?? raw.fat_bruto, 'lives e vendas do período', 'brand'),
      moneyMetric('Pipeline aberto', resumo.pipeline_aberto ?? raw.valor_pipeline ?? raw.pipeline_aberto, 'oportunidades comerciais', 'info'),
      percentMetric('Taxa de conversão', raw.taxa_conversao ?? resumo.taxa_conversao, 'últimos 90 dias', 'success'),
      metric('Clientes ativos', resumo.clientes_ativos ?? raw.clientes_ativos ?? 0, 'contratos faturando', 'neutral'),
    ],
    liveCabines,
    alerts: [
      metric('Contratos aguardando', alertas.contratos_aguardando_assinatura ?? raw.contratos_aguardando_assinatura ?? 0, 'assinatura pendente', 'warning'),
      metric('Boletos vencidos', alertas.boletos_vencidos ?? raw.boletos_vencidos ?? 0, 'atenção financeira', 'danger'),
      metric('Conflitos de agenda', alertas.conflitos_agenda ?? raw.conflitos_agenda ?? 0, 'próximas 48h', 'neutral'),
    ],
    occupancy: {
      live: asNumber(ocupacao.ao_vivo ?? liveCabines.length),
      total: asNumber(ocupacao.operacionais ?? cabines.length),
    },
    ranking: asArray<JsonRecord>(raw.ranking ?? raw.ranking_clientes ?? raw.top_clientes),
    upcoming: asArray<JsonRecord>(raw.proximas_lives_dia ?? raw.proximas_lives),
  }
}

export function normalizeMaster(raw: JsonRecord) {
  const cards = getRecord(raw.cards)
  return {
    metrics: [
      moneyMetric('GMV da rede', cards.gmv_rede ?? raw.gmv_rede ?? raw.gmv_total, 'rede consolidada', 'brand'),
      metric('Unidades ativas', cards.unidades_ativas ?? raw.unidades_ativas ?? 0, 'franquias em operação', 'neutral'),
      metric('Clientes ativos', cards.clientes_ativos ?? raw.clientes_ativos ?? 0, 'clientes faturando', 'success'),
      moneyMetric('Comissões', cards.comissoes ?? raw.comissoes ?? getRecord(raw.commissionSummary).total, 'base de repasse', 'info'),
    ],
    history: historyPoints(raw.networkHistory ?? raw.history ?? raw.historico),
    growth: historyPoints(raw.unitGrowth ?? raw.crescimento_unidades, ['tenant_nome', 'nome', 'label'], ['growth', 'crescimento', 'gmv']),
    ranking: asArray<JsonRecord>(raw.revenueRanking ?? raw.ranking ?? raw.ranking_receita),
    alerts: asArray<JsonRecord>(raw.alerts ?? raw.alertas),
    pipeline: asArray<JsonRecord>(raw.crmPipeline ?? raw.pipeline),
  }
}

export function normalizeCliente(raw: JsonRecord) {
  return {
    metrics: [
      moneyMetric('GMV', raw.gmv ?? raw.gmv_mes ?? raw.gmv_total, 'vendas atribuídas às lives', 'brand'),
      moneyMetric('Valor investido', raw.valor_investido_lives ?? raw.valor_investido, 'proporcional a horas usadas', 'info'),
      metric('Lives realizadas', raw.total_lives ?? raw.lives_realizadas ?? 0, 'no período selecionado', 'neutral'),
      percentMetric('ROAS', raw.roas ?? raw.roas_mes, 'retorno sobre investimento', 'success'),
      metric('Horas de live', asNumber(raw.horas_live ?? raw.horas_live_mes).toFixed(1), 'consumo do pacote', 'neutral'),
      percentMetric('Meta GMV', raw.pct_meta ?? raw.percentual_meta, asString(raw.status_meta, 'ritmo do mês'), 'warning'),
    ],
    history: historyPoints(raw.historico_mensal ?? raw.history ?? raw.evolucao_mensal),
    upcoming: asArray<JsonRecord>(raw.proximas_lives),
    liveAtiva: getRecord(raw.live_ativa),
    lives: asArray<JsonRecord>(raw.lives),
    topHorarios: asArray<JsonRecord>(raw.top_horarios ?? raw.melhores_horarios),
  }
}
