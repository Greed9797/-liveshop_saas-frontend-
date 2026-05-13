import { ClipboardCheck, Edit2, PhoneCall, Plus, Search, Trash2, Workflow, Zap } from 'lucide-react'
import { FormEvent, useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { PageHeader } from '../components/ui/PageHeader'
import { MetricCard } from '../components/ui/MetricCard'
import { Card, CardBody, CardHeader } from '../components/ui/Card'
import { Badge } from '../components/ui/Badge'
import { DataTable } from '../components/ui/DataTable'
import { Button } from '../components/ui/Button'
import { ErrorState, LoadingState } from '../components/ui/States'
import { addLeadContato, addLeadTarefa, createLead, deleteLead, getCrmSummary, getLeads, updateLead } from '../services/domain'
import { extractErrorMessage } from '../services/api'
import { asArray, asNumber, asString, formatMoney, getRecord } from '../utils/format'
import { metric, moneyMetric } from './page-helpers'
import type { JsonRecord, Lead } from '../types/models'

const crmEtapas = ['lead_novo', 'contato_iniciado', 'reuniao_agendada', 'proposta_enviada', 'em_negociacao', 'aguardando_assinatura', 'ganho', 'perdido']

const emptyLeadForm = {
  nome: '',
  nicho: '',
  origem: 'Cliente',
  cidade: '',
  estado: '',
  valor_oportunidade: '',
  responsavel_nome: '',
  crm_etapa: 'lead_novo',
}

export function CrmPage() {
  const [filter, setFilter] = useState('Todos')
  const [search, setSearch] = useState('')
  const [showForm, setShowForm] = useState(false)
  const [editingId, setEditingId] = useState('')
  const [leadForm, setLeadForm] = useState(emptyLeadForm)
  const client = useQueryClient()
  const summaryQuery = useQuery({ queryKey: ['crm-summary'], queryFn: getCrmSummary })
  const leadsQuery = useQuery({ queryKey: ['leads'], queryFn: getLeads })
  const saveMutation = useMutation({
    mutationFn: (payload: JsonRecord) => editingId ? updateLead(editingId, payload) : createLead(payload),
    onSuccess: () => {
      setShowForm(false)
      setEditingId('')
      setLeadForm(emptyLeadForm)
      void client.invalidateQueries({ queryKey: ['leads'] })
      void client.invalidateQueries({ queryKey: ['crm-summary'] })
    },
  })
  const updateMutation = useMutation({
    mutationFn: ({ id, payload }: { id: string; payload: JsonRecord }) => updateLead(id, payload),
    onSuccess: () => {
      void client.invalidateQueries({ queryKey: ['leads'] })
      void client.invalidateQueries({ queryKey: ['crm-summary'] })
    },
  })
  const deleteMutation = useMutation({
    mutationFn: deleteLead,
    onSuccess: () => {
      void client.invalidateQueries({ queryKey: ['leads'] })
      void client.invalidateQueries({ queryKey: ['crm-summary'] })
    },
  })
  const contatoMutation = useMutation({
    mutationFn: (id: string) => addLeadContato(id, { tipo: 'whatsapp', resumo: 'Contato registrado pelo painel React.' }),
    onSuccess: () => void client.invalidateQueries({ queryKey: ['leads'] }),
  })
  const tarefaMutation = useMutation({
    mutationFn: (id: string) => addLeadTarefa(id, { titulo: 'Follow-up comercial', concluida: false }),
    onSuccess: () => void client.invalidateQueries({ queryKey: ['leads'] }),
  })

  if (summaryQuery.isLoading || leadsQuery.isLoading) return <LoadingState />
  if (summaryQuery.isError) return <ErrorState message={extractErrorMessage(summaryQuery.error)} onRetry={() => void summaryQuery.refetch()} />
  if (leadsQuery.isError) return <ErrorState message={extractErrorMessage(leadsQuery.error)} onRetry={() => void leadsQuery.refetch()} />

  const raw = summaryQuery.data ?? {}
  const summary = getRecord(raw.summary)
  const totals = getRecord(raw.totals)
  const pipeline = asArray<JsonRecord>(raw.pipeline)
  const leads = leadsQuery.data ?? []
  const filters = ['Todos', 'Cliente', 'Creator', 'Unidade']
  const visibleLeads = leads.filter((lead) => {
    const record = lead as Lead & JsonRecord
    const type = asString(record.nicho ?? record.origem)
    const text = `${record.nome ?? ''} ${record.nome_cliente ?? ''} ${record.cliente_nome ?? ''} ${record.origem ?? ''} ${record.nicho ?? ''} ${record.etapa ?? ''} ${record.crm_etapa ?? ''}`.toLowerCase()
    const matchesType = filter === 'Todos' || type.toLowerCase().includes(filter.toLowerCase())
    return matchesType && text.includes(search.trim().toLowerCase())
  })
  const metrics = [
    metric('Leads', summary.total_leads ?? totals.total_leads ?? leads.length, 'CRM consolidado', 'neutral'),
    moneyMetric('Valor estimado', summary.valor_estimado ?? totals.valor_estimado ?? totals.valor_pipeline, 'pipeline aberto', 'brand'),
    metric('Ganhos', summary.ganhos ?? totals.ganhos ?? 0, 'clientes convertidos', 'success'),
    metric('Perdidos', summary.perdidos ?? totals.perdidos ?? 0, 'oportunidades perdidas', 'danger'),
  ]

  function setLeadField(key: keyof typeof emptyLeadForm, value: string) {
    setLeadForm((current) => ({ ...current, [key]: value }))
  }

  function openCreateForm() {
    setEditingId('')
    setLeadForm(emptyLeadForm)
    setShowForm(true)
  }

  function openEditForm(lead: Lead) {
    const record = lead as Lead & JsonRecord
    setEditingId(lead.id)
    setLeadForm({
      nome: asString(record.nome ?? record.nome_cliente ?? record.cliente_nome, ''),
      nicho: asString(record.nicho, ''),
      origem: asString(record.origem, 'Cliente'),
      cidade: asString(record.cidade, ''),
      estado: asString(record.estado, ''),
      valor_oportunidade: asString(record.valor_oportunidade ?? record.valor_estimado, ''),
      responsavel_nome: asString(record.responsavel_nome, ''),
      crm_etapa: asString(record.crm_etapa ?? record.etapa ?? record.status, 'lead_novo'),
    })
    setShowForm(true)
  }

  function onLeadSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    saveMutation.mutate({
      nome: leadForm.nome,
      nicho: leadForm.nicho || undefined,
      origem: leadForm.origem || undefined,
      cidade: leadForm.cidade || undefined,
      estado: leadForm.estado || undefined,
      valor_oportunidade: asNumber(leadForm.valor_oportunidade),
      responsavel_nome: leadForm.responsavel_nome || undefined,
      crm_etapa: leadForm.crm_etapa,
    })
  }

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="CRM"
        accent="Pipeline"
        title="comercial"
        subtitle="Leads, origem e etapa atual mapeados a partir do backend existente."
        actions={<Button icon={Plus} onClick={openCreateForm}>Novo lead</Button>}
      />

      {showForm ? (
        <Card>
          <CardHeader>
            <p className="text-base font-bold text-ink">{editingId ? 'Editar lead' : 'Novo lead'}</p>
          </CardHeader>
          <CardBody>
            <form className="grid gap-4 md:grid-cols-2 xl:grid-cols-4" onSubmit={onLeadSubmit}>
              <label className="block xl:col-span-2">
                <span className="text-sm font-semibold text-ink">Nome</span>
                <input className="design-input mt-2 h-11 w-full px-4" value={leadForm.nome} onChange={(event) => setLeadField('nome', event.target.value)} required />
              </label>
              <label className="block">
                <span className="text-sm font-semibold text-ink">Tipo/origem</span>
                <input className="design-input mt-2 h-11 w-full px-4" value={leadForm.origem} onChange={(event) => setLeadField('origem', event.target.value)} />
              </label>
              <label className="block">
                <span className="text-sm font-semibold text-ink">Nicho</span>
                <input className="design-input mt-2 h-11 w-full px-4" value={leadForm.nicho} onChange={(event) => setLeadField('nicho', event.target.value)} />
              </label>
              <label className="block">
                <span className="text-sm font-semibold text-ink">Cidade</span>
                <input className="design-input mt-2 h-11 w-full px-4" value={leadForm.cidade} onChange={(event) => setLeadField('cidade', event.target.value)} />
              </label>
              <label className="block">
                <span className="text-sm font-semibold text-ink">UF</span>
                <input className="design-input mt-2 h-11 w-full px-4" value={leadForm.estado} onChange={(event) => setLeadField('estado', event.target.value)} maxLength={2} />
              </label>
              <label className="block">
                <span className="text-sm font-semibold text-ink">Valor</span>
                <input className="design-input mt-2 h-11 w-full px-4" type="number" min="0" step="0.01" value={leadForm.valor_oportunidade} onChange={(event) => setLeadField('valor_oportunidade', event.target.value)} />
              </label>
              <label className="block">
                <span className="text-sm font-semibold text-ink">Etapa</span>
                <select className="design-input mt-2 h-11 w-full px-4" value={leadForm.crm_etapa} onChange={(event) => setLeadField('crm_etapa', event.target.value)}>
                  {crmEtapas.map((etapa) => <option key={etapa} value={etapa}>{etapa}</option>)}
                </select>
              </label>
              <label className="block md:col-span-2 xl:col-span-4">
                <span className="text-sm font-semibold text-ink">Responsável</span>
                <input className="design-input mt-2 h-11 w-full px-4" value={leadForm.responsavel_nome} onChange={(event) => setLeadField('responsavel_nome', event.target.value)} />
              </label>
              {saveMutation.isError ? <p className="md:col-span-2 xl:col-span-4 rounded-2xl bg-[var(--danger-soft)] px-4 py-3 text-sm font-medium text-[var(--danger)]">{extractErrorMessage(saveMutation.error)}</p> : null}
              <div className="flex flex-wrap gap-2 md:col-span-2 xl:col-span-4">
                <Button type="submit" icon={Plus} isLoading={saveMutation.isPending}>{editingId ? 'Salvar lead' : 'Criar lead'}</Button>
                <Button type="button" variant="secondary" onClick={() => setShowForm(false)}>Cancelar</Button>
              </div>
            </form>
          </CardBody>
        </Card>
      ) : null}

      <Card className="brand-hero border-brand/20">
        <CardBody className="flex flex-col gap-4 md:flex-row md:items-center">
          <span className="grid h-12 w-12 shrink-0 place-items-center rounded-2xl bg-white/15">
            <Zap className="h-6 w-6" />
          </span>
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.14em] text-white/75">CRM Livelab</p>
            <p className="mt-1 max-w-3xl text-sm leading-6 text-white/90">
              Funil preparado para Cliente, Creator e Unidade, mantendo as etapas do backend e a leitura executiva do handoff.
            </p>
          </div>
        </CardBody>
      </Card>

      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {metrics.map((item) => (
          <MetricCard key={item.label} metric={item} icon={Workflow} />
        ))}
      </section>

      <Card>
        <CardBody className="flex flex-col gap-3 p-4 lg:flex-row lg:items-center lg:justify-between">
          <div className="design-input flex h-11 min-w-0 flex-1 items-center gap-2 px-3">
            <Search className="h-4 w-4 shrink-0 text-ink-muted" />
            <input
              className="min-w-0 flex-1 bg-transparent text-sm outline-none placeholder:text-ink-muted"
              placeholder="Buscar lead, origem ou etapa"
              value={search}
              onChange={(event) => setSearch(event.target.value)}
            />
          </div>
          <div className="flex flex-wrap gap-2">
            {filters.map((item) => (
              <button
                key={item}
                className={filter === item ? 'rounded-full border border-brand bg-brand-soft px-3 py-2 text-xs font-bold text-brand' : 'rounded-full border border-line bg-surface px-3 py-2 text-xs font-semibold text-ink-muted hover:bg-surface-muted'}
                onClick={() => setFilter(item)}
              >
                {item}
              </button>
            ))}
          </div>
        </CardBody>
      </Card>

      <section className="grid gap-4 lg:grid-cols-4">
        {(pipeline.length ? pipeline : [{ etapa: 'Entrada', total: leads.length, valor: 0 }]).map((stage, index) => (
          <Card key={index} className="min-h-64">
            <CardHeader>
              <div className="flex items-center justify-between gap-2">
                <div className="flex min-w-0 items-center gap-2">
                  <span className="h-2.5 w-2.5 rounded-full bg-brand" />
                  <p className="truncate text-sm font-bold text-ink">{asString(stage.etapa ?? stage.stage ?? stage.label, 'Etapa')}</p>
                </div>
                <Badge tone="brand">{asNumber(stage.total ?? stage.count ?? stage.quantidade)}</Badge>
              </div>
            </CardHeader>
            <CardBody className="space-y-3">
              <p className="num text-xs font-semibold text-ink-muted">{formatMoney(stage.valor ?? stage.value)}</p>
              {visibleLeads
                .filter((lead) => {
                  const record = lead as Lead & JsonRecord
                  return !stage.etapa || record.crm_etapa === stage.etapa || record.etapa === stage.etapa || record.status === stage.etapa
                })
                .slice(0, 4)
                .map((lead) => (
                  <div key={lead.id} className="rounded-2xl border border-line bg-surface-muted p-3">
                    <div className="flex items-start justify-between gap-2">
                      <p className="min-w-0 truncate text-sm font-bold text-ink">{asString(lead.nome ?? lead.nome_cliente ?? lead.cliente_nome, 'Lead')}</p>
                      <span className="rounded-full bg-brand-soft px-2 py-1 text-[10px] font-bold uppercase text-brand">
                        {asString(lead.nicho ?? lead.origem, 'Lead')}
                      </span>
                    </div>
                    <p className="mt-2 text-xs text-ink-muted">{formatMoney(lead.valor_estimado)}</p>
                  </div>
                ))}
              {visibleLeads.filter((lead) => {
                const record = lead as Lead & JsonRecord
                return !stage.etapa || record.crm_etapa === stage.etapa || record.etapa === stage.etapa || record.status === stage.etapa
              }).length === 0 ? (
                <p className="rounded-xl border border-dashed border-line p-4 text-center text-xs text-ink-muted">vazio</p>
              ) : null}
            </CardBody>
          </Card>
        ))}
      </section>

      <Card>
        <CardHeader>
          <p className="text-sm font-bold text-ink">Lista de leads</p>
        </CardHeader>
        <CardBody>
          <DataTable<Lead>
            data={visibleLeads}
            columns={[
              { key: 'nome', header: 'Lead', render: (item) => asString(item.nome ?? item.nome_cliente ?? item.cliente_nome) },
              { key: 'nicho', header: 'Tipo/origem', render: (item) => asString(item.nicho ?? item.origem) },
              {
                key: 'etapa',
                header: 'Etapa',
                render: (item) => {
                  const record = item as Lead & JsonRecord
                  const etapa = asString(record.crm_etapa ?? record.etapa ?? record.status, 'lead_novo')
                  return (
                    <select
                      className="design-input h-9 min-w-44 px-3 text-xs"
                      value={etapa}
                      onChange={(event) => updateMutation.mutate({ id: item.id, payload: { crm_etapa: event.target.value } })}
                    >
                      {crmEtapas.map((option) => <option key={option} value={option}>{option}</option>)}
                    </select>
                  )
                },
              },
              { key: 'valor_estimado', header: 'Valor', align: 'right', render: (item) => formatMoney((item as Lead & JsonRecord).valor_oportunidade ?? item.valor_estimado) },
              {
                key: 'acoes',
                header: 'Ações',
                align: 'right',
                render: (item) => (
                  <div className="flex flex-wrap justify-end gap-2">
                    <Button variant="ghost" icon={PhoneCall} disabled={contatoMutation.isPending} onClick={() => void contatoMutation.mutate(item.id)}>Contato</Button>
                    <Button variant="ghost" icon={ClipboardCheck} disabled={tarefaMutation.isPending} onClick={() => void tarefaMutation.mutate(item.id)}>Tarefa</Button>
                    <Button variant="secondary" icon={Edit2} onClick={() => openEditForm(item)}>Editar</Button>
                    <Button variant="danger" icon={Trash2} disabled={deleteMutation.isPending} onClick={() => void deleteMutation.mutate(item.id)}>Excluir</Button>
                  </div>
                ),
              },
            ]}
          />
          {updateMutation.isError || deleteMutation.isError || contatoMutation.isError || tarefaMutation.isError ? (
            <p className="mt-4 rounded-2xl bg-[var(--danger-soft)] px-4 py-3 text-sm font-medium text-[var(--danger)]">
              {extractErrorMessage(updateMutation.error ?? deleteMutation.error ?? contatoMutation.error ?? tarefaMutation.error)}
            </p>
          ) : null}
        </CardBody>
      </Card>
    </div>
  )
}
