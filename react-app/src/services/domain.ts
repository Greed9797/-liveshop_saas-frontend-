import type { Cabine, JsonRecord, Lead, Period, Solicitacao } from '../types/models'
import { apiDelete, apiGet, apiPatch, apiPost } from './api'
import { periodToParam } from '../utils/format'

export function getHomeDashboard() {
  return apiGet<JsonRecord>('/home/dashboard')
}

export function getMasterDashboard(period: Period) {
  return apiGet<JsonRecord>('/master/dashboard', { periodo: periodToParam(period) })
}

export function getMasterUnits(period: Period, status = 'all') {
  return apiGet<JsonRecord>('/master/unidades', { periodo: periodToParam(period), status })
}

export function getMasterConsolidated(period: Period, status = 'all') {
  return apiGet<JsonRecord>('/master/consolidado', { periodo: periodToParam(period), status })
}

export function getCrmSummary() {
  return apiGet<JsonRecord>('/crm/summary')
}

export function getLeads() {
  return apiGet<Lead[]>('/leads')
}

export function createLead(payload: Partial<Lead>) {
  return apiPost<Lead>('/leads', payload)
}

export function updateLead(id: string, payload: Partial<Lead>) {
  return apiPatch<Lead>(`/leads/${id}`, payload)
}

export function deleteLead(id: string) {
  return apiDelete(`/leads/${id}`)
}

export function getClienteDashboard(period: Period) {
  return apiGet<JsonRecord>('/cliente/dashboard', { mes: period.mes, ano: period.ano })
}

export function getClienteLives(period: Period) {
  return apiGet<JsonRecord>('/cliente/lives', { mes: period.mes, ano: period.ano })
}

export function getClienteAgenda() {
  return apiGet<JsonRecord>('/cliente/agenda')
}

export function solicitarClienteLive(payload: JsonRecord) {
  return apiPost<JsonRecord>('/cliente/solicitacao', payload)
}

export function getCabines() {
  return apiGet<Cabine[]>('/cabines')
}

export function getCabinesFilaAtivacao() {
  return apiGet<JsonRecord[]>('/cabines/fila-ativacao')
}

export function liberarCabine(id: string) {
  return apiPatch(`/cabines/${id}/liberar`, {})
}

export function reservarCabine(id: string, clienteId: string) {
  return apiPatch(`/cabines/${id}/reservar`, { cliente_id: clienteId })
}

export function getLives() {
  return apiGet<JsonRecord[]>('/lives')
}

export function encerrarLive(id: string, payload: JsonRecord) {
  return apiPatch(`/lives/${id}/encerrar`, payload)
}

export function getSolicitacoes(status = 'all') {
  return apiGet<Solicitacao[]>('/solicitacoes', { status })
}

export function aprovarSolicitacao(id: string) {
  return apiPatch(`/solicitacoes/${id}/aprovar`, {})
}

export function recusarSolicitacao(id: string, motivo?: string) {
  return apiPatch(`/solicitacoes/${id}/recusar`, { motivo })
}

export function getApresentadoras() {
  return apiGet<JsonRecord[]>('/apresentadoras')
}

export function getAnalyticsDashboard(filters: Record<string, unknown> = {}) {
  return apiGet<JsonRecord>('/analytics/dashboard', filters)
}

export function getFinanceiroResumo(filters: Record<string, unknown> = {}) {
  return apiGet<JsonRecord>('/financeiro/resumo', filters)
}

export function getFinanceiroFluxo(filters: Record<string, unknown> = {}) {
  return apiGet<JsonRecord>('/financeiro/fluxo-caixa', filters)
}

export function getFinanceiroFaturamento(filters: Record<string, unknown> = {}) {
  return apiGet<JsonRecord>('/financeiro/faturamento', filters)
}

export function getBoletos() {
  return apiGet<JsonRecord[]>('/boletos')
}

export function getConfiguracoes() {
  return apiGet<JsonRecord>('/configuracoes')
}

export function updateConfiguracoes(payload: JsonRecord) {
  return apiPatch<JsonRecord>('/configuracoes', payload)
}

export function getKnowledgeCategories() {
  return apiGet<JsonRecord[]>('/knowledge/categories')
}

export function getKnowledgeArticles(params: Record<string, unknown> = {}) {
  return apiGet<JsonRecord[]>('/knowledge/articles', params)
}
