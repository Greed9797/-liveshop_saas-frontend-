import { Power, Presentation, RefreshCcw } from 'lucide-react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { PageHeader } from '../components/ui/PageHeader'
import { Card, CardBody, CardHeader } from '../components/ui/Card'
import { Badge, statusTone } from '../components/ui/Badge'
import { Button } from '../components/ui/Button'
import { ErrorState, LoadingState } from '../components/ui/States'
import { getCabines, liberarCabine } from '../services/domain'
import { extractErrorMessage } from '../services/api'
import { asNumber, asString, formatMoney } from '../utils/format'

export function CabinesPage({ title = 'Cabines' }: { title?: string }) {
  const client = useQueryClient()
  const query = useQuery({ queryKey: ['cabines'], queryFn: getCabines, refetchInterval: 20_000 })
  const liberarMutation = useMutation({
    mutationFn: liberarCabine,
    onSuccess: () => client.invalidateQueries({ queryKey: ['cabines'] }),
  })

  if (query.isLoading) return <LoadingState />
  if (query.isError) return <ErrorState message={extractErrorMessage(query.error)} onRetry={() => void query.refetch()} />

  const cabines = query.data ?? []

  return (
    <div className="space-y-6">
      <PageHeader
        eyebrow="Operação"
        accent={title}
        title="e lives"
        subtitle="Status das cabines, lives ativas, GMV atual e ações operacionais básicas."
        actions={
          <Button variant="secondary" icon={RefreshCcw} onClick={() => void query.refetch()}>
            Atualizar
          </Button>
        }
      />

      <section className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3 2xl:grid-cols-4">
        {cabines.map((cabine) => {
          const live = cabine.status === 'ao_vivo'
          return (
            <Card key={cabine.id} className={live ? 'border-emerald-200 bg-emerald-50/60' : undefined}>
              <CardHeader>
                <div className="flex items-center justify-between gap-3">
                  <div className="flex items-center gap-3">
                    <span className="rounded-md bg-white p-2 text-brand shadow-sm">
                      <Presentation className="h-5 w-5" />
                    </span>
                    <div>
                      <p className="text-base font-bold text-ink">Cabine {String(cabine.numero ?? '').padStart(2, '0')}</p>
                      <p className="text-xs text-ink-muted">{asString(cabine.cliente_nome, 'sem cliente vinculado')}</p>
                    </div>
                  </div>
                  <Badge tone={statusTone(cabine.status)}>{asString(cabine.status)}</Badge>
                </div>
              </CardHeader>
              <CardBody className="space-y-4">
                <div className="grid grid-cols-3 gap-2 text-center">
                  <div className="rounded-lg bg-white p-3">
                    <p className="text-xs text-ink-muted">Viewers</p>
                    <p className="font-bold text-ink">{asNumber(cabine.viewer_count).toLocaleString('pt-BR')}</p>
                  </div>
                  <div className="rounded-lg bg-white p-3">
                    <p className="text-xs text-ink-muted">GMV</p>
                    <p className="font-bold text-ink">{formatMoney(cabine.gmv_atual)}</p>
                  </div>
                  <div className="rounded-lg bg-white p-3">
                    <p className="text-xs text-ink-muted">Pedidos</p>
                    <p className="font-bold text-ink">{asNumber(cabine.total_orders).toLocaleString('pt-BR')}</p>
                  </div>
                </div>

                <div className="flex flex-wrap gap-2">
                  <Button
                    variant="ghost"
                    icon={Power}
                    disabled={!cabine.id || liberarMutation.isPending}
                    onClick={() => void liberarMutation.mutate(cabine.id)}
                  >
                    Liberar
                  </Button>
                </div>
              </CardBody>
            </Card>
          )
        })}
      </section>
    </div>
  )
}
