import { CircleDollarSign, Receipt, TrendingDown, TrendingUp } from 'lucide-react'
import { useQuery } from '@tanstack/react-query'
import { PageHeader } from '../components/ui/PageHeader'
import { MetricCard } from '../components/ui/MetricCard'
import { LinePanel } from '../components/charts/Charts'
import { Card, CardBody, CardHeader } from '../components/ui/Card'
import { DataTable } from '../components/ui/DataTable'
import { ErrorState, LoadingState } from '../components/ui/States'
import { getFinanceiroFaturamento, getFinanceiroFluxo, getFinanceiroResumo } from '../services/domain'
import { extractErrorMessage } from '../services/api'
import { asArray, asNumber, asString, formatMoney } from '../utils/format'
import { historyPoints, metric, moneyMetric } from './page-helpers'
import type { JsonRecord } from '../types/models'

const icons = [CircleDollarSign, TrendingUp, TrendingDown, Receipt]

export function FinanceiroPage() {
  const resumo = useQuery({ queryKey: ['financeiro-resumo'], queryFn: () => getFinanceiroResumo() })
  const fluxo = useQuery({ queryKey: ['financeiro-fluxo'], queryFn: () => getFinanceiroFluxo() })
  const faturamento = useQuery({ queryKey: ['financeiro-faturamento'], queryFn: () => getFinanceiroFaturamento() })

  if (resumo.isLoading || fluxo.isLoading || faturamento.isLoading) return <LoadingState />
  if (resumo.isError) return <ErrorState message={extractErrorMessage(resumo.error)} onRetry={() => void resumo.refetch()} />

  const raw = resumo.data ?? {}
  const metrics = [
    moneyMetric('Receita', raw.receita ?? raw.fat_bruto ?? raw.fat_total, 'período atual', 'brand'),
    moneyMetric('Recebido', raw.recebido ?? raw.pago, 'caixa confirmado', 'success'),
    moneyMetric('Em aberto', raw.em_aberto ?? raw.a_receber, 'pendente de pagamento', 'warning'),
    metric('Boletos vencidos', raw.boletos_vencidos ?? 0, 'requer cobrança', 'danger'),
  ]

  return (
    <div className="space-y-6">
      <PageHeader eyebrow="Financeiro" accent="Resumo" title="da unidade" subtitle="Receita, fluxo de caixa, faturamento e pendências." />
      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-4">
        {metrics.map((item, index) => (
          <MetricCard key={item.label} metric={item} icon={icons[index]} />
        ))}
      </section>

      <section className="grid gap-4 xl:grid-cols-2">
        <LinePanel title="Fluxo de caixa" data={historyPoints(fluxo.data?.items ?? fluxo.data?.fluxo ?? fluxo.data?.history)} />
        <Card>
          <CardHeader>
            <p className="text-sm font-bold text-ink">Faturamento por cliente</p>
          </CardHeader>
          <CardBody>
            <DataTable<JsonRecord>
              data={asArray<JsonRecord>(faturamento.data?.clientes ?? faturamento.data?.items ?? faturamento.data)}
              columns={[
                { key: 'cliente_nome', header: 'Cliente', render: (item) => asString(item.cliente_nome ?? item.nome) },
                { key: 'valor', header: 'Valor', align: 'right', render: (item) => formatMoney(item.valor ?? item.faturamento) },
                { key: 'lives', header: 'Lives', align: 'right', render: (item) => asNumber(item.lives ?? item.total_lives).toLocaleString('pt-BR') },
              ]}
            />
          </CardBody>
        </Card>
      </section>
    </div>
  )
}
