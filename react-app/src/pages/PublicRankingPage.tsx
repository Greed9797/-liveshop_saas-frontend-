import { Trophy, Users, Video } from 'lucide-react'
import { useQuery } from '@tanstack/react-query'
import { Link } from 'react-router-dom'
import { Card, CardBody, CardHeader } from '../components/ui/Card'
import { DataTable } from '../components/ui/DataTable'
import { ErrorState, LoadingState } from '../components/ui/States'
import { getPublicRanking } from '../services/domain'
import { extractErrorMessage } from '../services/api'
import { asNumber, asString, formatMoney, formatPercent } from '../utils/format'
import type { JsonRecord } from '../types/models'

export function PublicRankingPage() {
  const query = useQuery({ queryKey: ['public-ranking'], queryFn: () => getPublicRanking() })

  if (query.isLoading) return <LoadingState label="Carregando ranking" />
  if (query.isError) return <ErrorState message={extractErrorMessage(query.error)} onRetry={() => void query.refetch()} />

  const ranking = query.data ?? []
  const leader = ranking[0]

  return (
    <main className="min-h-screen bg-canvas px-4 py-6 text-ink md:px-8">
      <div className="mx-auto max-w-6xl space-y-6">
        <header className="flex flex-col gap-4 border-b border-line pb-5 md:flex-row md:items-center md:justify-between">
          <div>
            <p className="text-xs font-bold uppercase tracking-[0.12em] text-brand">Livelab</p>
            <h1 className="mt-2 text-3xl font-extrabold tracking-[-0.02em]">Ranking comercial</h1>
            <p className="mt-2 max-w-2xl text-sm text-ink-muted">Top unidades por GMV do mês, lives realizadas e clientes ativos.</p>
          </div>
          <Link className="inline-flex h-11 items-center justify-center rounded-full border border-line bg-surface px-5 text-sm font-bold text-ink transition hover:bg-surface-muted" to="/login">
            Acessar painel
          </Link>
        </header>

        {leader ? (
          <section className="grid gap-4 md:grid-cols-3">
            <Card className="border-brand/25">
              <CardBody className="p-5">
                <span className="grid h-11 w-11 place-items-center rounded-xl bg-brand-soft text-brand"><Trophy className="h-5 w-5" /></span>
                <p className="mt-5 text-xs font-bold uppercase tracking-[0.12em] text-ink-muted">Lider do mês</p>
                <p className="mt-2 text-2xl font-extrabold text-ink">{asString(leader.nome)}</p>
              </CardBody>
            </Card>
            <Card>
              <CardBody className="p-5">
                <span className="grid h-11 w-11 place-items-center rounded-xl bg-[var(--success-soft)] text-[var(--success)]"><Video className="h-5 w-5" /></span>
                <p className="mt-5 text-xs font-bold uppercase tracking-[0.12em] text-ink-muted">Lives</p>
                <p className="num mt-2 text-2xl font-extrabold text-ink">{asNumber(leader.total_lives).toLocaleString('pt-BR')}</p>
              </CardBody>
            </Card>
            <Card>
              <CardBody className="p-5">
                <span className="grid h-11 w-11 place-items-center rounded-xl bg-[var(--info-soft)] text-[var(--info)]"><Users className="h-5 w-5" /></span>
                <p className="mt-5 text-xs font-bold uppercase tracking-[0.12em] text-ink-muted">Clientes ativos</p>
                <p className="num mt-2 text-2xl font-extrabold text-ink">{asNumber(leader.total_clientes_ativos).toLocaleString('pt-BR')}</p>
              </CardBody>
            </Card>
          </section>
        ) : null}

        <Card>
          <CardHeader>
            <p className="text-base font-bold text-ink">Top unidades</p>
          </CardHeader>
          <CardBody>
            <DataTable<JsonRecord>
              data={ranking}
              columns={[
                { key: 'posicao', header: '#', align: 'center', render: (item) => asNumber(item.posicao).toLocaleString('pt-BR') },
                { key: 'nome', header: 'Unidade', render: (item) => asString(item.nome) },
                { key: 'gmv_mes', header: 'GMV mes', align: 'right', render: (item) => formatMoney(item.gmv_mes) },
                { key: 'crescimento_pct', header: 'Crescimento', align: 'right', render: (item) => formatPercent(item.crescimento_pct) },
                { key: 'total_lives', header: 'Lives', align: 'right', render: (item) => asNumber(item.total_lives).toLocaleString('pt-BR') },
                { key: 'total_clientes_ativos', header: 'Clientes ativos', align: 'right', render: (item) => asNumber(item.total_clientes_ativos).toLocaleString('pt-BR') },
              ]}
            />
          </CardBody>
        </Card>
      </div>
    </main>
  )
}
