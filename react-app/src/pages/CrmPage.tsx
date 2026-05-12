import { Workflow } from 'lucide-react'
import { useQuery } from '@tanstack/react-query'
import { PageHeader } from '../components/ui/PageHeader'
import { MetricCard } from '../components/ui/MetricCard'
import { Card, CardBody, CardHeader } from '../components/ui/Card'
import { Badge, statusTone } from '../components/ui/Badge'
import { DataTable } from '../components/ui/DataTable'
import { ErrorState, LoadingState } from '../components/ui/States'
import { getCrmSummary, getLeads } from '../services/domain'
import { extractErrorMessage } from '../services/api'
import { asArray, asNumber, asString, formatMoney, getRecord } from '../utils/format'
import { metric, moneyMetric } from './page-helpers'
import type { JsonRecord, Lead } from '../types/models'

export function CrmPage() {
  const summaryQuery = useQuery({ queryKey: ['crm-summary'], queryFn: getCrmSummary })
  const leadsQuery = useQuery({ queryKey: ['leads'], queryFn: getLeads })

  if (summaryQuery.isLoading || leadsQuery.isLoading) return <LoadingState />
  if (summaryQuery.isError) return <ErrorState message={extractErrorMessage(summaryQuery.error)} onRetry={() => void summaryQuery.refetch()} />
  if (leadsQuery.isError) return <ErrorState message={extractErrorMessage(leadsQuery.error)} onRetry={() => void leadsQuery.refetch()} />

  const raw = summaryQuery.data ?? {}
  const summary = getRecord(raw.summary)
  const totals = getRecord(raw.totals)
  const pipeline = asArray<JsonRecord>(raw.pipeline)
  const leads = leadsQuery.data ?? []
  const metrics = [
    metric('Leads', summary.total_leads ?? totals.total_leads ?? leads.length, 'CRM consolidado', 'neutral'),
    moneyMetric('Valor estimado', summary.valor_estimado ?? totals.valor_estimado ?? totals.valor_pipeline, 'pipeline aberto', 'brand'),
    metric('Ganhos', summary.ganhos ?? totals.ganhos ?? 0, 'clientes convertidos', 'success'),
    metric('Perdidos', summary.perdidos ?? totals.perdidos ?? 0, 'oportunidades perdidas', 'danger'),
  ]

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="CRM"
        accent="Pipeline"
        title="comercial"
        subtitle="Leads, origem e etapa atual mapeados a partir do backend existente."
      />

      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {metrics.map((item) => (
          <MetricCard key={item.label} metric={item} icon={Workflow} />
        ))}
      </section>

      <section className="grid gap-4 lg:grid-cols-4">
        {(pipeline.length ? pipeline : [{ etapa: 'Entrada', total: leads.length, valor: 0 }]).map((stage, index) => (
          <Card key={index} className="min-h-56">
            <CardHeader>
              <div className="flex items-center justify-between gap-2">
                <p className="text-sm font-bold text-ink">{asString(stage.etapa ?? stage.stage ?? stage.label, 'Etapa')}</p>
                <Badge tone="brand">{asNumber(stage.total ?? stage.count ?? stage.quantidade)}</Badge>
              </div>
            </CardHeader>
            <CardBody className="space-y-3">
              <p className="text-xs text-ink-muted">{formatMoney(stage.valor ?? stage.value)}</p>
              {leads
                .filter((lead) => !stage.etapa || lead.etapa === stage.etapa || lead.status === stage.etapa)
                .slice(0, 4)
                .map((lead) => (
                  <div key={lead.id} className="rounded-lg border border-line bg-surface-muted p-3">
                    <p className="text-sm font-bold text-ink">{asString(lead.nome ?? lead.nome_cliente ?? lead.cliente_nome, 'Lead')}</p>
                    <p className="mt-1 text-xs text-ink-muted">{asString(lead.origem ?? lead.nicho, 'origem não informada')}</p>
                  </div>
                ))}
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
            data={leads}
            columns={[
              { key: 'nome', header: 'Lead', render: (item) => asString(item.nome ?? item.nome_cliente ?? item.cliente_nome) },
              { key: 'nicho', header: 'Tipo/origem', render: (item) => asString(item.nicho ?? item.origem) },
              { key: 'etapa', header: 'Etapa', render: (item) => <Badge tone={statusTone(item.etapa ?? item.status)}>{asString(item.etapa ?? item.status)}</Badge> },
              { key: 'valor_estimado', header: 'Valor', align: 'right', render: (item) => formatMoney(item.valor_estimado) },
            ]}
          />
        </CardBody>
      </Card>
    </div>
  )
}
