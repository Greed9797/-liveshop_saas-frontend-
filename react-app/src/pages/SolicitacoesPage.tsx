import { Check, X } from 'lucide-react'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { PageHeader } from '../components/ui/PageHeader'
import { Card, CardBody, CardHeader } from '../components/ui/Card'
import { DataTable } from '../components/ui/DataTable'
import { Badge, statusTone } from '../components/ui/Badge'
import { Button } from '../components/ui/Button'
import { ErrorState, LoadingState } from '../components/ui/States'
import { aprovarSolicitacao, getSolicitacoes, recusarSolicitacao } from '../services/domain'
import { extractErrorMessage } from '../services/api'
import { asString, formatDate } from '../utils/format'
import type { Solicitacao } from '../types/models'

export function SolicitacoesPage() {
  const client = useQueryClient()
  const query = useQuery({ queryKey: ['solicitacoes'], queryFn: () => getSolicitacoes('all') })
  const approve = useMutation({
    mutationFn: aprovarSolicitacao,
    onSuccess: () => client.invalidateQueries({ queryKey: ['solicitacoes'] }),
  })
  const reject = useMutation({
    mutationFn: (id: string) => recusarSolicitacao(id, 'Recusado pelo painel React'),
    onSuccess: () => client.invalidateQueries({ queryKey: ['solicitacoes'] }),
  })

  if (query.isLoading) return <LoadingState />
  if (query.isError) return <ErrorState message={extractErrorMessage(query.error)} onRetry={() => void query.refetch()} />

  return (
    <div className="space-y-6">
      <PageHeader eyebrow="Operação" accent="Solicitações" title="de live" subtitle="Aprovação e recusa de reservas solicitadas pelos clientes." />
      <Card>
        <CardHeader>
          <p className="text-sm font-bold text-ink">Fila de solicitações</p>
        </CardHeader>
        <CardBody>
          <DataTable<Solicitacao>
            data={query.data ?? []}
            columns={[
              { key: 'cliente_nome', header: 'Cliente', render: (item) => asString(item.cliente_nome) },
              { key: 'data_solicitada', header: 'Data', render: (item) => formatDate(item.data_solicitada) },
              { key: 'hora_inicio', header: 'Hora', render: (item) => asString(item.hora_inicio) },
              { key: 'cabine_numero', header: 'Cabine', render: (item) => `Cabine ${asString(item.cabine_numero)}` },
              { key: 'status', header: 'Status', render: (item) => <Badge tone={statusTone(item.status)}>{asString(item.status)}</Badge> },
              {
                key: 'acoes',
                header: 'Ações',
                render: (item) => (
                  <div className="flex justify-end gap-2">
                    <Button variant="secondary" icon={Check} disabled={approve.isPending} onClick={() => void approve.mutate(item.id)}>
                      Aprovar
                    </Button>
                    <Button variant="ghost" icon={X} disabled={reject.isPending} onClick={() => void reject.mutate(item.id)}>
                      Recusar
                    </Button>
                  </div>
                ),
                align: 'right',
              },
            ]}
          />
        </CardBody>
      </Card>
    </div>
  )
}
