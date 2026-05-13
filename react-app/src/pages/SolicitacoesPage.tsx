import { CalendarClock, Check, Clock, ListFilter, Plus, Search, Video, X } from 'lucide-react'
import { FormEvent, useState } from 'react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { PageHeader } from '../components/ui/PageHeader'
import { Card, CardBody } from '../components/ui/Card'
import { Badge, statusTone } from '../components/ui/Badge'
import { Button } from '../components/ui/Button'
import { EmptyState, ErrorState, LoadingState } from '../components/ui/States'
import { aprovarSolicitacao, criarSolicitacao, getApresentadoras, getCabines, getClientes, getSolicitacoes, recusarSolicitacao } from '../services/domain'
import { extractErrorMessage } from '../services/api'
import { asString, formatDate } from '../utils/format'
import { useCurrentUser } from '../stores/auth-store'

const writeSolicitacoesRoles = new Set(['franqueador_master', 'franqueado', 'gerente', 'produtor_live'])

const emptyAgendamento = {
  cabine_id: '',
  cliente_id: '',
  apresentadora_id: '',
  data_solicitada: new Date().toISOString().slice(0, 10),
  hora_inicio: '10:00',
  hora_fim: '12:00',
  observacao: '',
}

export function SolicitacoesPage() {
  const user = useCurrentUser()
  const canWrite = writeSolicitacoesRoles.has(user?.papel ?? '')
  const [tab, setTab] = useState<'pendentes' | 'todas'>('pendentes')
  const [statusFilter, setStatusFilter] = useState('Todos')
  const [search, setSearch] = useState('')
  const [showCreate, setShowCreate] = useState(false)
  const [agendamento, setAgendamento] = useState(emptyAgendamento)
  const client = useQueryClient()
  const query = useQuery({ queryKey: ['solicitacoes'], queryFn: () => getSolicitacoes('all') })
  const clientesQuery = useQuery({ queryKey: ['clientes'], queryFn: getClientes, enabled: showCreate && canWrite })
  const cabinesQuery = useQuery({ queryKey: ['cabines'], queryFn: getCabines, enabled: showCreate && canWrite })
  const apresentadorasQuery = useQuery({ queryKey: ['apresentadoras'], queryFn: getApresentadoras, enabled: showCreate && canWrite })
  const approve = useMutation({
    mutationFn: aprovarSolicitacao,
    onSuccess: () => client.invalidateQueries({ queryKey: ['solicitacoes'] }),
  })
  const reject = useMutation({
    mutationFn: (id: string) => recusarSolicitacao(id, 'Recusado pelo painel React'),
    onSuccess: () => client.invalidateQueries({ queryKey: ['solicitacoes'] }),
  })
  const create = useMutation({
    mutationFn: criarSolicitacao,
    onSuccess: () => {
      setShowCreate(false)
      setAgendamento(emptyAgendamento)
      void client.invalidateQueries({ queryKey: ['solicitacoes'] })
    },
  })

  if (query.isLoading) return <LoadingState />
  if (query.isError) return <ErrorState message={extractErrorMessage(query.error)} onRetry={() => void query.refetch()} />

  const solicitacoes = query.data ?? []
  const pendentes = solicitacoes.filter((item) => asString(item.status).toLowerCase().includes('pend'))
  const aprovadas = solicitacoes.filter((item) => asString(item.status).toLowerCase().includes('aprov'))
  const recusadas = solicitacoes.filter((item) => asString(item.status).toLowerCase().includes('recus'))
  const taxa = solicitacoes.length ? Math.round((aprovadas.length / solicitacoes.length) * 100) : null
  const rows = (tab === 'pendentes' ? pendentes : solicitacoes).filter((item) => {
    const normalizedStatus = asString(item.status)
    const statusMatch = statusFilter === 'Todos' || normalizedStatus.toLowerCase().includes(statusFilter.toLowerCase())
    const text = `${item.cliente_nome ?? ''} ${item.cabine_numero ?? ''} ${item.solicitante_nome ?? ''} ${item.tipo_live ?? ''}`.toLowerCase()
    return statusMatch && text.includes(search.trim().toLowerCase())
  })

  function setAgendamentoField(key: keyof typeof emptyAgendamento, value: string) {
    setAgendamento((current) => ({ ...current, [key]: value }))
  }

  function onCreateSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    create.mutate({
      cabine_id: agendamento.cabine_id,
      cliente_id: agendamento.cliente_id,
      apresentadora_id: agendamento.apresentadora_id || null,
      data_solicitada: agendamento.data_solicitada,
      hora_inicio: agendamento.hora_inicio,
      hora_fim: agendamento.hora_fim,
      observacao: agendamento.observacao || undefined,
    })
  }

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Agenda operacional"
        accent="Solicitações"
        title="de lives"
        subtitle="Aprove, recuse e acompanhe pedidos de horário dos clientes."
        actions={canWrite ? <Button icon={Plus} onClick={() => setShowCreate(true)}>Novo Agendamento</Button> : undefined}
      />

      {showCreate && canWrite ? (
        <Card>
          <CardBody>
            <form className="grid gap-4 md:grid-cols-2 xl:grid-cols-4" onSubmit={onCreateSubmit}>
              <label className="block">
                <span className="text-sm font-semibold text-ink">Cabine</span>
                <select className="design-input mt-2 h-11 w-full px-4" value={agendamento.cabine_id} onChange={(event) => setAgendamentoField('cabine_id', event.target.value)} required>
                  <option value="">Selecione</option>
                  {(cabinesQuery.data ?? []).map((cabine) => <option key={cabine.id} value={cabine.id}>Cabine {cabine.numero}</option>)}
                </select>
              </label>
              <label className="block">
                <span className="text-sm font-semibold text-ink">Cliente</span>
                <select className="design-input mt-2 h-11 w-full px-4" value={agendamento.cliente_id} onChange={(event) => setAgendamentoField('cliente_id', event.target.value)} required>
                  <option value="">Selecione</option>
                  {(clientesQuery.data ?? []).map((cliente) => <option key={asString(cliente.id)} value={asString(cliente.id)}>{asString(cliente.nome)}</option>)}
                </select>
              </label>
              <label className="block">
                <span className="text-sm font-semibold text-ink">Apresentadora</span>
                <select className="design-input mt-2 h-11 w-full px-4" value={agendamento.apresentadora_id} onChange={(event) => setAgendamentoField('apresentadora_id', event.target.value)}>
                  <option value="">Sem vínculo</option>
                  {(apresentadorasQuery.data ?? []).map((apresentadora) => <option key={asString(apresentadora.id)} value={asString(apresentadora.id)}>{asString(apresentadora.nome)}</option>)}
                </select>
              </label>
              <label className="block">
                <span className="text-sm font-semibold text-ink">Data</span>
                <input className="design-input mt-2 h-11 w-full px-4" type="date" value={agendamento.data_solicitada} onChange={(event) => setAgendamentoField('data_solicitada', event.target.value)} required />
              </label>
              <label className="block">
                <span className="text-sm font-semibold text-ink">Início</span>
                <input className="design-input mt-2 h-11 w-full px-4" type="time" value={agendamento.hora_inicio} onChange={(event) => setAgendamentoField('hora_inicio', event.target.value)} required />
              </label>
              <label className="block">
                <span className="text-sm font-semibold text-ink">Fim</span>
                <input className="design-input mt-2 h-11 w-full px-4" type="time" value={agendamento.hora_fim} onChange={(event) => setAgendamentoField('hora_fim', event.target.value)} required />
              </label>
              <label className="block md:col-span-2">
                <span className="text-sm font-semibold text-ink">Observação</span>
                <input className="design-input mt-2 h-11 w-full px-4" value={agendamento.observacao} onChange={(event) => setAgendamentoField('observacao', event.target.value)} />
              </label>
              {clientesQuery.isError || cabinesQuery.isError || apresentadorasQuery.isError || create.isError ? (
                <p className="md:col-span-2 xl:col-span-4 rounded-2xl bg-[var(--danger-soft)] px-4 py-3 text-sm font-medium text-[var(--danger)]">
                  {extractErrorMessage(clientesQuery.error ?? cabinesQuery.error ?? apresentadorasQuery.error ?? create.error)}
                </p>
              ) : null}
              <div className="flex flex-wrap gap-2 md:col-span-2 xl:col-span-4">
                <Button type="submit" icon={Plus} isLoading={create.isPending || clientesQuery.isLoading || cabinesQuery.isLoading}>Criar agendamento</Button>
                <Button type="button" variant="secondary" onClick={() => setShowCreate(false)}>Cancelar</Button>
              </div>
            </form>
          </CardBody>
        </Card>
      ) : null}

      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {[
          ['Pendentes', pendentes.length, 'aguardando aprovação', 'brand'],
          ['Aprovadas', aprovadas.length, 'neste período', 'success'],
          ['Recusadas', recusadas.length, 'conflitos ou indisponibilidade', 'danger'],
          ['Taxa aprovação', taxa === null ? '—' : `${taxa}%`, 'aprovadas / total', 'neutral'],
        ].map(([label, value, sub, tone]) => (
          <Card key={String(label)} className={tone === 'brand' ? 'border-brand/30' : undefined}>
            <CardBody className="p-5">
              <p className="text-xs font-semibold uppercase tracking-[0.12em] text-ink-muted">{label}</p>
              <p className="num mt-3 text-[34px] font-bold leading-none text-ink">{value}</p>
              <p className="mt-2 text-xs text-ink-muted">{sub}</p>
            </CardBody>
          </Card>
        ))}
      </section>

      <div className="flex flex-col gap-3 lg:flex-row lg:items-center lg:justify-between">
        <div className="inline-flex rounded-2xl border border-line bg-surface p-1">
          <button className={tab === 'pendentes' ? 'rounded-xl bg-brand px-4 py-2 text-sm font-bold text-white' : 'rounded-xl px-4 py-2 text-sm font-semibold text-ink-muted'} onClick={() => setTab('pendentes')}>
            <Clock className="mr-2 inline h-4 w-4" /> Pendentes
          </button>
          <button className={tab === 'todas' ? 'rounded-xl bg-brand px-4 py-2 text-sm font-bold text-white' : 'rounded-xl px-4 py-2 text-sm font-semibold text-ink-muted'} onClick={() => setTab('todas')}>
            <ListFilter className="mr-2 inline h-4 w-4" /> Todas
          </button>
        </div>
        <div className="flex flex-col gap-2 md:flex-row">
          {tab === 'todas' ? (
            <div className="flex flex-wrap gap-2">
              {['Todos', 'Pendente', 'Aprovada', 'Recusada'].map((status) => (
                <button key={status} className={statusFilter === status ? 'rounded-full border border-brand bg-brand-soft px-3 py-2 text-xs font-bold text-brand' : 'rounded-full border border-line bg-surface px-3 py-2 text-xs font-semibold text-ink-muted'} onClick={() => setStatusFilter(status)}>
                  {status}
                </button>
              ))}
            </div>
          ) : null}
          <div className="design-input flex h-10 min-w-64 items-center gap-2 px-3">
            <Search className="h-4 w-4 text-ink-muted" />
            <input className="min-w-0 flex-1 bg-transparent text-sm outline-none placeholder:text-ink-muted" placeholder="Cliente ou cabine" value={search} onChange={(event) => setSearch(event.target.value)} />
          </div>
        </div>
      </div>

      <section className="space-y-3">
        {rows.length === 0 ? <EmptyState title={tab === 'pendentes' ? 'Nenhum agendamento pendente' : 'Nenhum agendamento encontrado'} description={tab === 'pendentes' ? 'Tudo em dia. Quando um cliente solicitar uma live, ela aparecerá aqui.' : 'Tente ajustar os filtros.'} /> : null}
        {rows.map((item) => (
          <Card key={item.id} className={asString(item.status).toLowerCase().includes('pend') ? 'border-brand/25' : undefined}>
            <CardBody className="flex flex-col gap-4 p-4 lg:flex-row lg:items-center lg:justify-between">
              <div className="flex min-w-0 gap-4">
                <div className="grid h-12 shrink-0 place-items-center rounded-xl bg-brand-soft px-3 text-[11px] font-bold uppercase tracking-[0.08em] text-brand">
                  Cabine {asString(item.cabine_numero, '—')}
                </div>
                <div className="min-w-0">
                  <p className="truncate text-base font-bold text-ink">{asString(item.cliente_nome, 'Cliente')}</p>
                  <div className="mt-2 flex flex-wrap gap-x-4 gap-y-1 text-xs text-ink-muted">
                    <span className="inline-flex items-center gap-1"><CalendarClock className="h-3.5 w-3.5" /> {formatDate(item.data_solicitada)} às {asString(item.hora_inicio)}</span>
                    <span className="inline-flex items-center gap-1"><Video className="h-3.5 w-3.5" /> {asString(item.tipo_live, 'live comercial')}</span>
                  </div>
                </div>
              </div>
              <div className="flex flex-wrap items-center justify-end gap-2">
                {asString(item.status).toLowerCase().includes('pend') ? (
                  <>
                    <Button variant="ghost" icon={X} disabled={reject.isPending} onClick={() => void reject.mutate(item.id)}>
                      Recusar
                    </Button>
                    <Button icon={Check} disabled={approve.isPending} onClick={() => void approve.mutate(item.id)}>
                      Aprovar
                    </Button>
                  </>
                ) : (
                  <Badge tone={statusTone(item.status)}>{asString(item.status)}</Badge>
                )}
              </div>
            </CardBody>
          </Card>
        ))}
      </section>

      {canWrite ? (
        <Button className="fixed bottom-5 right-5 z-20 h-12 shadow-[0_8px_24px_-6px_var(--primary)]" icon={Plus} onClick={() => setShowCreate(true)}>
          Novo Agendamento
        </Button>
      ) : null}
    </div>
  )
}
